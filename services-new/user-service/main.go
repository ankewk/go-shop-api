package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lib/pq"
)

type UserService struct {
	router *gin.Engine
	db     *sql.DB
	config *Config
}

type Config struct {
	Port     string
	DBHost   string
	DBPort   string
	DBUser   string
	DBPassword string
	DBName   string
}

type User struct {
	ID        int64     `json:"id"`
	Username  string    `json:"username"`
	Email     string    `json:"email"`
	Role      string    `json:"role"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type UserProfile struct {
	ID        int64     `json:"id"`
	UserID    int64     `json:"user_id"`
	FirstName string    `json:"first_name"`
	LastName  string    `json:"last_name"`
	Phone     string    `json:"phone"`
	Avatar    string    `json:"avatar"`
	Birthday  *time.Time `json:"birthday,omitempty"`
	Gender    string    `json:"gender"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type UserAddress struct {
	ID        int64     `json:"id"`
	UserID    int64     `json:"user_id"`
	Type      string    `json:"type"` // billing, shipping
	Name      string    `json:"name"`
	Phone     string    `json:"phone"`
	Address   string    `json:"address"`
	City      string    `json:"city"`
	State     string    `json:"state"`
	ZipCode   string    `json:"zip_code"`
	Country   string    `json:"country"`
	IsDefault bool      `json:"is_default"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type UpdateUserRequest struct {
	Username  string `json:"username"`
	Email     string `json:"email"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Phone     string `json:"phone"`
	Avatar    string `json:"avatar"`
	Birthday  *time.Time `json:"birthday"`
	Gender    string `json:"gender"`
}

type CreateAddressRequest struct {
	Type      string `json:"type" binding:"required"`
	Name      string `json:"name" binding:"required"`
	Phone     string `json:"phone" binding:"required"`
	Address   string `json:"address" binding:"required"`
	City      string `json:"city" binding:"required"`
	State     string `json:"state" binding:"required"`
	ZipCode   string `json:"zip_code" binding:"required"`
	Country   string `json:"country" binding:"required"`
	IsDefault bool   `json:"is_default"`
}

func NewUserService(config *Config) *UserService {
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

	service := &UserService{
		router: gin.Default(),
		db:     db,
		config: config,
	}

	service.setupRoutes()
	return service
}

func initDB(db *sql.DB) error {
	// 创建用户档案表
	query := `
	CREATE TABLE IF NOT EXISTS user_profiles (
		id SERIAL PRIMARY KEY,
		user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
		first_name VARCHAR(100),
		last_name VARCHAR(100),
		phone VARCHAR(20),
		avatar VARCHAR(500),
		birthday DATE,
		gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		UNIQUE(user_id)
	);

	CREATE TABLE IF NOT EXISTS user_addresses (
		id SERIAL PRIMARY KEY,
		user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
		type VARCHAR(20) CHECK (type IN ('billing', 'shipping')),
		name VARCHAR(100) NOT NULL,
		phone VARCHAR(20) NOT NULL,
		address TEXT NOT NULL,
		city VARCHAR(100) NOT NULL,
		state VARCHAR(100) NOT NULL,
		zip_code VARCHAR(20) NOT NULL,
		country VARCHAR(100) NOT NULL,
		is_default BOOLEAN DEFAULT FALSE,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);

	CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON user_profiles(user_id);
	CREATE INDEX IF NOT EXISTS idx_user_addresses_user_id ON user_addresses(user_id);
	CREATE INDEX IF NOT EXISTS idx_user_addresses_user_type ON user_addresses(user_id, type);
	`
	
	_, err := db.Exec(query)
	return err
}

func (s *UserService) setupRoutes() {
	// 健康检查
	s.router.GET("/health", s.healthHandler)

	// API路由
	api := s.router.Group("/api/v1")
	{
		// 用户相关
		users := api.Group("/users")
		{
			users.GET("/:id", s.getUserHandler)
			users.PUT("/:id", s.updateUserHandler)
			users.DELETE("/:id", s.deleteUserHandler)
			
			// 用户档案
			users.GET("/:id/profile", s.getUserProfileHandler)
			users.PUT("/:id/profile", s.updateUserProfileHandler)
			
			// 用户地址
			users.GET("/:id/addresses", s.getUserAddressesHandler)
			users.POST("/:id/addresses", s.createUserAddressHandler)
			users.PUT("/:id/addresses/:addressId", s.updateUserAddressHandler)
			users.DELETE("/:id/addresses/:addressId", s.deleteUserAddressHandler)
		}
	}
}

func (s *UserService) healthHandler(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status": "healthy",
		"service": "user-service",
		"timestamp": time.Now().Format(time.RFC3339),
	})
}

func (s *UserService) getUserHandler(c *gin.Context) {
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

func (s *UserService) updateUserHandler(c *gin.Context) {
	userID := c.Param("id")
	
	var req UpdateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 更新用户基本信息
	if req.Username != "" || req.Email != "" {
		query := `UPDATE users SET 
			username = COALESCE(NULLIF($1, ''), username),
			email = COALESCE(NULLIF($2, ''), email),
			updated_at = CURRENT_TIMESTAMP
			WHERE id = $3`
		
		_, err := s.db.Exec(query, req.Username, req.Email, userID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update user"})
			return
		}
	}

	// 更新用户档案
	if req.FirstName != "" || req.LastName != "" || req.Phone != "" || 
	   req.Avatar != "" || req.Birthday != nil || req.Gender != "" {
		
		query := `INSERT INTO user_profiles (user_id, first_name, last_name, phone, avatar, birthday, gender)
				VALUES ($1, $2, $3, $4, $5, $6, $7)
				ON CONFLICT (user_id) DO UPDATE SET
				first_name = COALESCE(NULLIF(EXCLUDED.first_name, ''), user_profiles.first_name),
				last_name = COALESCE(NULLIF(EXCLUDED.last_name, ''), user_profiles.last_name),
				phone = COALESCE(NULLIF(EXCLUDED.phone, ''), user_profiles.phone),
				avatar = COALESCE(NULLIF(EXCLUDED.avatar, ''), user_profiles.avatar),
				birthday = COALESCE(EXCLUDED.birthday, user_profiles.birthday),
				gender = COALESCE(NULLIF(EXCLUDED.gender, ''), user_profiles.gender),
				updated_at = CURRENT_TIMESTAMP`
		
		_, err := s.db.Exec(query, userID, req.FirstName, req.LastName, req.Phone, 
			req.Avatar, req.Birthday, req.Gender)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update user profile"})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{"message": "user updated successfully"})
}

func (s *UserService) deleteUserHandler(c *gin.Context) {
	userID := c.Param("id")
	
	// 删除用户（级联删除相关数据）
	_, err := s.db.Exec("DELETE FROM users WHERE id = $1", userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to delete user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "user deleted successfully"})
}

func (s *UserService) getUserProfileHandler(c *gin.Context) {
	userID := c.Param("id")
	
	var profile UserProfile
	query := `SELECT id, user_id, first_name, last_name, phone, avatar, birthday, gender, created_at, updated_at
				FROM user_profiles WHERE user_id = $1`
	
	err := s.db.QueryRow(query, userID).Scan(
		&profile.ID, &profile.UserID, &profile.FirstName, &profile.LastName,
		&profile.Phone, &profile.Avatar, &profile.Birthday, &profile.Gender,
		&profile.CreatedAt, &profile.UpdatedAt,
	)
	
	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "user profile not found"})
		return
	}
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "database error"})
		return
	}

	c.JSON(http.StatusOK, profile)
}

func (s *UserService) updateUserProfileHandler(c *gin.Context) {
	userID := c.Param("id")
	
	var req UpdateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	query := `INSERT INTO user_profiles (user_id, first_name, last_name, phone, avatar, birthday, gender)
				VALUES ($1, $2, $3, $4, $5, $6, $7)
				ON CONFLICT (user_id) DO UPDATE SET
				first_name = COALESCE(NULLIF(EXCLUDED.first_name, ''), user_profiles.first_name),
				last_name = COALESCE(NULLIF(EXCLUDED.last_name, ''), user_profiles.last_name),
				phone = COALESCE(NULLIF(EXCLUDED.phone, ''), user_profiles.phone),
				avatar = COALESCE(NULLIF(EXCLUDED.avatar, ''), user_profiles.avatar),
				birthday = COALESCE(EXCLUDED.birthday, user_profiles.birthday),
				gender = COALESCE(NULLIF(EXCLUDED.gender, ''), user_profiles.gender),
				updated_at = CURRENT_TIMESTAMP`
	
	_, err := s.db.Exec(query, userID, req.FirstName, req.LastName, req.Phone, 
		req.Avatar, req.Birthday, req.Gender)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update user profile"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "user profile updated successfully"})
}

func (s *UserService) getUserAddressesHandler(c *gin.Context) {
	userID := c.Param("id")
	
	query := `SELECT id, user_id, type, name, phone, address, city, state, zip_code, country, is_default, created_at, updated_at
				FROM user_addresses WHERE user_id = $1 ORDER BY is_default DESC, created_at DESC`
	
	rows, err := s.db.Query(query, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "database error"})
		return
	}
	defer rows.Close()

	var addresses []UserAddress
	for rows.Next() {
		var address UserAddress
		err := rows.Scan(
			&address.ID, &address.UserID, &address.Type, &address.Name, &address.Phone,
			&address.Address, &address.City, &address.State, &address.ZipCode, &address.Country,
			&address.IsDefault, &address.CreatedAt, &address.UpdatedAt,
		)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to scan address"})
			return
		}
		addresses = append(addresses, address)
	}

	c.JSON(http.StatusOK, addresses)
}

func (s *UserService) createUserAddressHandler(c *gin.Context) {
	userID := c.Param("id")
	
	var req CreateAddressRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 如果设置为默认地址，先清除其他默认地址
	if req.IsDefault {
		_, err := s.db.Exec("UPDATE user_addresses SET is_default = FALSE WHERE user_id = $1 AND type = $2", userID, req.Type)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update default addresses"})
			return
		}
	}

	query := `INSERT INTO user_addresses (user_id, type, name, phone, address, city, state, zip_code, country, is_default)
				VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
				RETURNING id, user_id, type, name, phone, address, city, state, zip_code, country, is_default, created_at, updated_at`
	
	var address UserAddress
	err := s.db.QueryRow(query, userID, req.Type, req.Name, req.Phone, req.Address, 
		req.City, req.State, req.ZipCode, req.Country, req.IsDefault).Scan(
		&address.ID, &address.UserID, &address.Type, &address.Name, &address.Phone,
		&address.Address, &address.City, &address.State, &address.ZipCode, &address.Country,
		&address.IsDefault, &address.CreatedAt, &address.UpdatedAt,
	)
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to create address"})
		return
	}

	c.JSON(http.StatusCreated, address)
}

func (s *UserService) updateUserAddressHandler(c *gin.Context) {
	userID := c.Param("id")
	addressID := c.Param("addressId")
	
	var req CreateAddressRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 如果设置为默认地址，先清除其他默认地址
	if req.IsDefault {
		_, err := s.db.Exec("UPDATE user_addresses SET is_default = FALSE WHERE user_id = $1 AND type = $2 AND id != $3", 
			userID, req.Type, addressID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update default addresses"})
			return
		}
	}

	query := `UPDATE user_addresses 
				SET name = $1, phone = $2, address = $3, city = $4, state = $5, 
					zip_code = $6, country = $7, is_default = $8, updated_at = CURRENT_TIMESTAMP
				WHERE id = $9 AND user_id = $10
				RETURNING id, user_id, type, name, phone, address, city, state, zip_code, country, is_default, created_at, updated_at`
	
	var address UserAddress
	err := s.db.QueryRow(query, req.Name, req.Phone, req.Address, req.City, req.State, 
		req.ZipCode, req.Country, req.IsDefault, addressID, userID).Scan(
		&address.ID, &address.UserID, &address.Type, &address.Name, &address.Phone,
		&address.Address, &address.City, &address.State, &address.ZipCode, &address.Country,
		&address.IsDefault, &address.CreatedAt, &address.UpdatedAt,
	)
	
	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "address not found"})
		return
	}
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update address"})
		return
	}

	c.JSON(http.StatusOK, address)
}

func (s *UserService) deleteUserAddressHandler(c *gin.Context) {
	userID := c.Param("id")
	addressID := c.Param("addressId")
	
	_, err := s.db.Exec("DELETE FROM user_addresses WHERE id = $1 AND user_id = $2", addressID, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to delete address"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "address deleted successfully"})
}

func (s *UserService) Start() error {
	server := &http.Server{
		Addr:    s.config.Port,
		Handler: s.router,
	}

	go func() {
		log.Printf("User Service starting on port %s", s.config.Port)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Failed to start User Service: %v", err)
		}
	}()

	// 等待中断信号
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("Shutting down User Service...")
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	return server.Shutdown(ctx)
}

func main() {
	config := &Config{
		Port:       ":8082",
		DBHost:     "localhost",
		DBPort:     "5432",
		DBUser:     "postgres",
		DBPassword: "password",
		DBName:     "user_db",
	}

	service := NewUserService(config)
	if err := service.Start(); err != nil {
		log.Fatal("Failed to start User Service:", err)
	}
}