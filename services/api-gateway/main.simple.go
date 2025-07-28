package main

import (
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

func main() {
	// 设置Gin模式
	if os.Getenv("GIN_MODE") == "" {
		gin.SetMode(gin.ReleaseMode)
	}

	// 创建Gin引擎
	r := gin.Default()

	// 添加中间件
	r.Use(gin.Logger())
	r.Use(gin.Recovery())

	// 健康检查
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "ok",
			"service": "api-gateway",
			"message": "API网关运行正常",
		})
	})

	// 根路径
	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "欢迎使用Go Shop微服务平台",
			"version": "1.0.0",
			"services": []string{
				"用户服务 (8085)",
				"产品服务 (8082)",
				"购物车服务 (8083)",
				"订单服务 (8084)",
			},
		})
	})

	// 服务列表
	r.GET("/services", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"services": map[string]interface{}{
				"user-service": map[string]string{
					"host": os.Getenv("USER_SERVICE_HOST"),
					"port": os.Getenv("USER_SERVICE_PORT"),
					"url":  "http://" + os.Getenv("USER_SERVICE_HOST") + ":" + os.Getenv("USER_SERVICE_PORT"),
				},
				"product-service": map[string]string{
					"host": os.Getenv("PRODUCT_SERVICE_HOST"),
					"port": os.Getenv("PRODUCT_SERVICE_PORT"),
					"url":  "http://" + os.Getenv("PRODUCT_SERVICE_HOST") + ":" + os.Getenv("PRODUCT_SERVICE_PORT"),
				},
				"cart-service": map[string]string{
					"host": os.Getenv("CART_SERVICE_HOST"),
					"port": os.Getenv("CART_SERVICE_PORT"),
					"url":  "http://" + os.Getenv("CART_SERVICE_HOST") + ":" + os.Getenv("CART_SERVICE_PORT"),
				},
				"order-service": map[string]string{
					"host": os.Getenv("ORDER_SERVICE_HOST"),
					"port": os.Getenv("ORDER_SERVICE_PORT"),
					"url":  "http://" + os.Getenv("ORDER_SERVICE_HOST") + ":" + os.Getenv("ORDER_SERVICE_PORT"),
				},
			},
		})
	})

	// API路由信息
	r.GET("/api-routes", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"gateway": "API网关 - 统一入口",
			"routes": map[string]string{
				"GET /":           "欢迎页面",
				"GET /health":     "健康检查",
				"GET /services":   "服务列表",
				"GET /api-routes": "API路由信息",
			},
			"microservices": map[string]string{
				"用户服务":  "http://localhost:8085/health",
				"产品服务":  "http://localhost:8082/health",
				"购物车服务": "http://localhost:8083/health",
				"订单服务":  "http://localhost:8084/health",
			},
		})
	})

	// 获取端口
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("🚀 API网关启动在端口 %s", port)
	log.Printf("📖 访问地址: http://localhost:%s", port)
	log.Printf("🔧 健康检查: http://localhost:%s/health", port)
	log.Printf("📋 服务列表: http://localhost:%s/services", port)

	// 启动服务器
	if err := r.Run(":" + port); err != nil {
		log.Fatal("🔥 启动API网关失败:", err)
	}
}
