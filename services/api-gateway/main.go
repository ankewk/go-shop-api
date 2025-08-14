package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-redis/redis/v8"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/time/rate"
)

type APIGateway struct {
	router *gin.Engine
	redis  *redis.Client
	config *Config
}

type Config struct {
	Port          string
	RedisURL      string
	Services      map[string]string
	JWTSecret     string
	RateLimitRPS  int
	RateLimitBurst int
}

type RateLimiter struct {
	limiters map[string]*rate.Limiter
}

func NewRateLimiter() *RateLimiter {
	return &RateLimiter{
		limiters: make(map[string]*rate.Limiter),
	}
}

func (rl *RateLimiter) getLimiter(key string) *rate.Limiter {
	limiter, exists := rl.limiters[key]
	if !exists {
		limiter = rate.NewLimiter(rate.Limit(100), 1000) // 100 RPS, burst 1000
		rl.limiters[key] = limiter
	}
	return limiter
}

func (rl *RateLimiter) Allow(key string) bool {
	return rl.getLimiter(key).Allow()
}

func NewAPIGateway(config *Config) *APIGateway {
	// 初始化Redis连接
	rdb := redis.NewClient(&redis.Options{
		Addr: config.RedisURL,
	})

	gateway := &APIGateway{
		router: gin.Default(),
		redis:  rdb,
		config: config,
	}

	// 配置中间件
	gateway.setupMiddleware()
	gateway.setupRoutes()

	return gateway
}

func (g *APIGateway) setupMiddleware() {
	// 全局中间件
	g.router.Use(gin.Logger())
	g.router.Use(gin.Recovery())
	g.router.Use(g.corsMiddleware())
	g.router.Use(g.rateLimitMiddleware())
}

func (g *APIGateway) corsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	}
}

func (g *APIGateway) rateLimitMiddleware() gin.HandlerFunc {
	rl := NewRateLimiter()
	
	return func(c *gin.Context) {
		clientIP := c.ClientIP()
		if !rl.Allow(clientIP) {
			c.JSON(http.StatusTooManyRequests, gin.H{
				"error": "rate limit exceeded",
			})
			c.Abort()
			return
		}
		c.Next()
	}
}

func (g *APIGateway) authMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "authorization header required"})
			c.Abort()
			return
		}

		tokenString := authHeader[len("Bearer "):]
		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
			}
			return []byte(g.config.JWTSecret), nil
		})

		if err != nil || !token.Valid {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
			c.Abort()
			return
		}

		claims := token.Claims.(jwt.MapClaims)
		c.Set("user_id", claims["user_id"])
		c.Set("user_role", claims["role"])
		c.Next()
	}
}

func (g *APIGateway) setupRoutes() {
	// 健康检查
	g.router.GET("/health", g.healthHandler)

	// 公开路由
	public := g.router.Group("/api/v1")
	{
		// 认证相关
		public.POST("/auth/login", g.proxyHandler(g.config.Services["auth-service"]))
		public.POST("/auth/register", g.proxyHandler(g.config.Services["auth-service"]))
		public.GET("/products", g.proxyHandler(g.config.Services["product-service"]))
		public.GET("/products/:id", g.proxyHandler(g.config.Services["product-service"]))
		public.GET("/search", g.proxyHandler(g.config.Services["search-service"]))
	}

	// 需要认证的路由
	protected := g.router.Group("/api/v1")
	protected.Use(g.authMiddleware())
	{
		// 用户相关
		protected.GET("/users/:id", g.proxyHandler(g.config.Services["user-service"]))
		protected.PUT("/users/:id", g.proxyHandler(g.config.Services["user-service"]))
		
		// 购物车
		protected.GET("/cart", g.proxyHandler(g.config.Services["cart-service"]))
		protected.POST("/cart/items", g.proxyHandler(g.config.Services["cart-service"]))
		protected.PUT("/cart/items/:id", g.proxyHandler(g.config.Services["cart-service"]))
		protected.DELETE("/cart/items/:id", g.proxyHandler(g.config.Services["cart-service"]))
		
		// 订单
		protected.POST("/orders", g.proxyHandler(g.config.Services["order-service"]))
		protected.GET("/orders/:id", g.proxyHandler(g.config.Services["order-service"]))
		protected.GET("/orders/user/:userId", g.proxyHandler(g.config.Services["order-service"]))
		
		// 支付
		protected.POST("/payments", g.proxyHandler(g.config.Services["payment-service"]))
		protected.GET("/payments/:id", g.proxyHandler(g.config.Services["payment-service"]))
		
		// 通知
		protected.GET("/notifications", g.proxyHandler(g.config.Services["notification-service"]))
		protected.PUT("/notifications/:id/read", g.proxyHandler(g.config.Services["notification-service"]))
	}
}

func (g *APIGateway) proxyHandler(targetService string) gin.HandlerFunc {
	return func(c *gin.Context) {
		// 构建目标URL
		targetURL := fmt.Sprintf("http://%s%s", targetService, c.Request.URL.Path)
		
		// 创建新的请求
		proxyReq, err := http.NewRequest(c.Request.Method, targetURL, c.Request.Body)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to create proxy request"})
			return
		}

		// 复制请求头
		for key, values := range c.Request.Header {
			for _, value := range values {
				proxyReq.Header.Add(key, value)
			}
		}

		// 添加用户上下文
		if userID, exists := c.Get("user_id"); exists {
			proxyReq.Header.Set("X-User-ID", fmt.Sprintf("%v", userID))
		}
		if userRole, exists := c.Get("user_role"); exists {
			proxyReq.Header.Set("X-User-Role", fmt.Sprintf("%v", userRole))
		}

		// 发送请求
		client := &http.Client{Timeout: 30 * time.Second}
		resp, err := client.Do(proxyReq)
		if err != nil {
			c.JSON(http.StatusServiceUnavailable, gin.H{"error": "service unavailable"})
			return
		}
		defer resp.Body.Close()

		// 复制响应头
		for key, values := range resp.Header {
			for _, value := range values {
				c.Header(key, value)
			}
		}

		// 设置状态码
		c.Status(resp.StatusCode)
		
		// 复制响应体
		_, err = io.Copy(c.Writer, resp.Body)
		if err != nil {
			log.Printf("Error copying response body: %v", err)
		}
	}
}

func (g *APIGateway) healthHandler(c *gin.Context) {
	// 检查所有下游服务
	health := map[string]interface{}{
		"status": "healthy",
		"services": make(map[string]string),
		"timestamp": time.Now().Format(time.RFC3339),
	}

	for serviceName, serviceURL := range g.config.Services {
		resp, err := http.Get(fmt.Sprintf("http://%s/health", serviceURL))
		if err != nil || resp.StatusCode != http.StatusOK {
			health["services"].(map[string]string)[serviceName] = "unhealthy"
		} else {
			health["services"].(map[string]string)[serviceName] = "healthy"
		}
	}

	c.JSON(http.StatusOK, health)
}

func (g *APIGateway) Start() error {
	server := &http.Server{
		Addr:    ":8080",
		Handler: g.router,
	}

	go func() {
		log.Printf("API Gateway starting on port %s", g.config.Port)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Failed to start API Gateway: %v", err)
		}
	}()

	// 等待中断信号
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("Shutting down API Gateway...")
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	return server.Shutdown(ctx)
}

func main() {
	config := &Config{
		Port:    ":8080",
		RedisURL: "localhost:6379",
		Services: map[string]string{
			"auth-service":       "localhost:8081",
			"user-service":       "localhost:8082",
			"order-service":      "localhost:8083",
			"product-service":    "localhost:8084",
			"cart-service":       "localhost:8085",
			"payment-service":    "localhost:8086",
			"notification-service": "localhost:8087",
			"search-service":     "localhost:8088",
		},
		JWTSecret:      "your-secret-key",
		RateLimitRPS:   100,
		RateLimitBurst: 1000,
	}

	gateway := NewAPIGateway(config)
	if err := gateway.Start(); err != nil {
		log.Fatal("Failed to start API Gateway:", err)
	}
}