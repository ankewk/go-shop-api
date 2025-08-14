package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/lib/pq"
	"golang.org/x/crypto/bcrypt"
)

type AuthService struct {
	router *gin.Engine
	db     *sql.DB
	config *Config
}

type Config struct {
	Port      string
	DBHost    string
	DBPort    string
	DBUser    string
	DBPassword string
	DBName    string
	JWTSecret string
	JWTExpiry time.Duration
}

type User struct {
	ID        int64     `json:"id"`
	Username  string    `json:"username"`
	Email     string    `json:"email"`
	Password  string    `json:"-"`
	Role      string    `json:"role"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type RegisterRequest struct {
	Username string `json:"username" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
}

type AuthResponse struct {
	Token   string    `json:"token"`
	User    User      `json:"user"`
	Expires time.Time `json:"expires_at"`
}

type TokenClaims struct {
	UserID int64  `json:"user_id"`
	Role   string `json:"role"`
	jwt.RegisteredClaims
}

func NewAuthService(config *Config) *AuthService {
	// 数据库连接字符串
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		config.DBHost, config.DBPort, config.DBUser, config.DBPassword, config.DBName)

	// 连接数据库
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// 测试连接
	if err := db.Ping(); err != nil {
		log.Fatal("Failed to ping database:", err)
	}

	// 初始化数据库表
	if err := initDB(db); err != nil {
		log.Fatal("Failed to initialize database:", err)
	}

	service := &AuthService{
		router: gin.Default(),
		db:     db,
		config: config,
	}

	service.setupRoutes()
	return service
}

func initDB(db *sql.DB) error {
	// 创建用户表
	query := `
	CREATE TABLE IF NOT EXISTS users (
		id SERIAL PRIMARY KEY,
		username VARCHAR(50) UNIQUE NOT NULL,
		email VARCHAR(100) UNIQUE NOT NULL,
		password_hash VARCHAR(255) NOT NULL,
		role VARCHAR(20) DEFAULT 'user',
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);
	
	CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
	CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
	`
	
	_, err := db.Exec(query)
	return err
}

func (s *AuthService) setupRoutes() {
	// 健康检查
	s.router.GET("/health", s.healthHandler)
	
	// API路由
	api := s.router.Group("/api/v1")
	{
		// 认证相关
		auth := api.Group("/auth")
		{
			auth.POST("/login", s.loginHandler)
			auth.POST("/register", s.registerHandler)
			auth.POST("/refresh", s.refreshTokenHandler)
			auth.POST("/logout", s.logoutHandler)
			auth.GET("/validate", s.validateTokenHandler)
		}
		
		// 用户相关
		users := api.Group("/users")
		{
			users.GET("/:id", s.getUserHandler)
			users.PUT("/:id", s.updateUserHandler)
			users.DELETE("/:id", s.deleteUserHandler)
		}
	}
}

func (s *AuthService) healthHandler(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status": "healthy",
		"service": "auth-service",
		"timestamp": time.Now().Format(time.RFC3339),
	})
}

func (s *AuthService) loginHandler(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 查询用户
	var user User
	query := `SELECT id, username, email, password_hash, role, created_at, updated_at 
				FROM users WHERE username = $1`
	
	err := s.db.QueryRow(query, req.Username).Scan(
		&user.ID, &user.Username, &user.Email, &user.Password, &user.Role,
		&user.CreatedAt, &user.UpdatedAt,
	)
	
	if err == sql.ErrNoRows {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		return
	}
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "database error"})
		return
	}

	// 验证密码
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		return
	}

	// 生成JWT令牌
	token, err := s.generateToken(user.ID, user.Role)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to generate token"})
		return
	}

	// 记录登录时间
	_, err = s.db.Exec("UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE id = $1", user.ID)
	if err != nil {
		log.Printf("Failed to update last login time: %v", err)
	}

	c.JSON(http.StatusOK, AuthResponse{
		Token:   token,
		User:    user,
		Expires: time.Now().Add(s.config.JWTExpiry),
	})
}

func (s *AuthService) registerHandler(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 检查用户名是否已存在
	var count int
	err := s.db.QueryRow("SELECT COUNT(*) FROM users WHERE username = $1", req.Username).Scan(&count)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "database error"})
		return
	}
	if count > 0 {
		c.JSON(http.StatusConflict, gin.H{"error": "username already exists"})
		return
	}

	// 检查邮箱是否已存在
	err = s.db.QueryRow("SELECT COUNT(*) FROM users WHERE email = $1", req.Email).Scan(&count)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "database error"})
		return
	}
	if count > 0 {
		c.JSON(http.StatusConflict, gin.H{"error": "email already exists"})
		return
	}

	// 加密密码
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to hash password"})
		return
	}

	// 创建用户
	var user User
	query := `INSERT INTO users (username, email, password_hash) 
				VALUES ($1, $2, $3) 
				RETURNING id, username, email, role, created_at, updated_at`
	
	err = s.db.QueryRow(query, req.Username, req.Email, string(hashedPassword)).Scan(
		&user.ID, &user.Username, &user.Email, &user.Role, &user.CreatedAt, &user.UpdatedAt,
	)
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to create user"})
		return
	}

	// 生成JWT令牌
	token, err := s.generateToken(user.ID, user.Role)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to generate token"})
		return
	}

	c.JSON(http.StatusCreated, AuthResponse{
		Token:   token,
		User:    user,
		Expires: time.Now().Add(s.config.JWTExpiry),
	})
}

func (s *AuthService) refreshTokenHandler(c *gin.Context) {
	var req struct {
		Token string `json:"token" binding:"required"`
	}
	
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 解析旧令牌
	oldToken, err := jwt.ParseWithClaims(req.Token, &TokenClaims{}, func(token *jwt.Token) (interface{}, error) {
		return []byte(s.config.JWTSecret), nil
	})
	
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
		return
	}

	if claims, ok := oldToken.Claims.(*TokenClaims); ok && oldToken.Valid {
		// 生成新令牌
		newToken, err := s.generateToken(claims.UserID, claims.Role)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to generate new token"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"token": newToken})
	} else {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
	}
}

func (s *AuthService) logoutHandler(c *gin.Context) {
	// 在实际应用中，这里可以处理令牌黑名单
	// 简单实现：客户端删除本地存储的令牌
	c.JSON(http.StatusOK, gin.H{"message": "logged out successfully"})
}

func (s *AuthService) validateTokenHandler(c *gin.Context) {
	var req struct {
		Token string `json:"token" binding:"required"`
	}
	
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 验证令牌
	token, err := jwt.ParseWithClaims(req.Token, &TokenClaims{}, func(token *jwt.Token) (interface{}, error) {
		return []byte(s.config.JWTSecret), nil
	})
	
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
		return
	}

	if claims, ok := token.Claims.(*TokenClaims); ok && token.Valid {
		c.JSON(http.StatusOK, gin.H{
			"valid": true,
			"user_id": claims.UserID,
			"role": claims.Role,
		})
	} else {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
	}
}

func (s *AuthService) getUserHandler(c *gin.Context) {
	userID := c.Param("id")
	
	var user User
	query := `SELECT id, username, email, role, created_at, updated_at 
				FROM users WHERE id = $1`
	
	err := s.db.QueryRow(query, userID).Scan(
		&user.ID, &user.Username, &user.Email, &user.Role,
		&user.CreatedAt, &user.UpdatedAt,
	)
	
	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "database error"})
		return
	}

	c.JSON(http.StatusOK, user)
}

func (s *AuthService) updateUserHandler(c *gin.Context) {
	// 实现用户更新逻辑
	c.JSON(http.StatusOK, gin.H{"message": "user updated"})
}

func (s *AuthService) deleteUserHandler(c *gin.Context) {
	// 实现用户删除逻辑
	c.JSON(http.StatusOK, gin.H{"message": "user deleted"})
}

func (s *AuthService) generateToken(userID int64, role string) (string, error) {
	claims := TokenClaims{
		UserID: userID,
		Role:   role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(s.config.JWTExpiry)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Issuer:    "go-shop-auth-service",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.config.JWTSecret))
}

func (s *AuthService) Start() error {
	server := &http.Server{
		Addr:    s.config.Port,
		Handler: s.router,
	}

	go func() {
		log.Printf("Auth Service starting on port %s", s.config.Port)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Failed to start Auth Service: %v", err)
		}
	}()

	// 等待中断信号
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("Shutting down Auth Service...")
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	return server.Shutdown(ctx)
}

func main() {
	config := &Config{
		Port:         ":8081",
		DBHost:       "localhost",
		DBPort:       "5432",
		DBUser:       "postgres",
		DBPassword:   "password",
		DBName:       "auth_db",
		JWTSecret:    "your-secret-key",
		JWTExpiry:    24 * time.Hour,
	}

	service := NewAuthService(config)
	if err := service.Start(); err != nil {
		log.Fatal("Failed to start Auth Service:", err)
	}
}