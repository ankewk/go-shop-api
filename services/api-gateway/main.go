package main

import (
	"bytes"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	_ "gin-project/services/api-gateway/docs"
	"gin-project/shared/response"

	"github.com/gin-gonic/gin"
	ginSwagger "github.com/swaggo/gin-swagger"
)

// ServiceConfig 服务配置
type ServiceConfig struct {
	Name string `json:"name"`
	Host string `json:"host"`
	Port string `json:"port"`
	URL  string `json:"url"`
}

// Gateway API网关
type Gateway struct {
	services map[string]*ServiceConfig
	client   *http.Client
}

// NewGateway 创建网关实例
func NewGateway() *Gateway {
	return &Gateway{
		services: make(map[string]*ServiceConfig),
		client: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// RegisterService 注册服务
func (gw *Gateway) RegisterService(name, host, port string) {
	url := fmt.Sprintf("http://%s:%s", host, port)
	gw.services[name] = &ServiceConfig{
		Name: name,
		Host: host,
		Port: port,
		URL:  url,
	}
	log.Printf("服务注册成功: %s -> %s", name, url)
}

// ProxyRequest 代理请求到后端服务
func (gw *Gateway) ProxyRequest(c *gin.Context) {
	path := c.Request.URL.Path

	// 解析服务名称和目标路径
	var serviceName string
	var targetPath string

	if strings.HasPrefix(path, "/api/v1/users") {
		serviceName = "user-service"
		targetPath = path
	} else if strings.HasPrefix(path, "/api/v1/products") {
		serviceName = "product-service"
		targetPath = path
	} else if strings.HasPrefix(path, "/api/v1/cart") {
		serviceName = "cart-service"
		targetPath = path
	} else if strings.HasPrefix(path, "/api/v1/orders") {
		serviceName = "order-service"
		targetPath = path
	} else {
		response.NotFound(c, "服务不存在")
		return
	}

	// 获取服务配置
	service, exists := gw.services[serviceName]
	if !exists {
		response.ServiceUnavailable(c, "服务不可用", serviceName+" 服务未注册")
		return
	}

	// 构建目标URL
	targetURL := service.URL + targetPath
	if c.Request.URL.RawQuery != "" {
		targetURL += "?" + c.Request.URL.RawQuery
	}

	// 读取请求体
	var bodyBytes []byte
	if c.Request.Body != nil {
		bodyBytes, _ = io.ReadAll(c.Request.Body)
		c.Request.Body = io.NopCloser(bytes.NewBuffer(bodyBytes))
	}

	// 创建新请求
	req, err := http.NewRequest(c.Request.Method, targetURL, bytes.NewBuffer(bodyBytes))
	if err != nil {
		response.InternalServerError(c, "创建请求失败", err.Error())
		return
	}

	// 复制请求头
	for name, values := range c.Request.Header {
		for _, value := range values {
			req.Header.Add(name, value)
		}
	}

	// 添加网关标识
	req.Header.Set("X-Gateway", "gin-api-gateway")
	req.Header.Set("X-Forwarded-For", c.ClientIP())

	// 发送请求
	resp, err := gw.client.Do(req)
	if err != nil {
		response.ServiceUnavailable(c, "服务请求失败", err.Error())
		return
	}
	defer resp.Body.Close()

	// 读取响应
	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		response.InternalServerError(c, "读取响应失败", err.Error())
		return
	}

	// 复制响应头
	for name, values := range resp.Header {
		for _, value := range values {
			c.Header(name, value)
		}
	}

	// 返回响应
	c.Data(resp.StatusCode, resp.Header.Get("Content-Type"), respBody)
}

// HealthCheck 健康检查
func (gw *Gateway) HealthCheck(c *gin.Context) {
	services := make(map[string]interface{})

	for name, service := range gw.services {
		healthURL := service.URL + "/health"
		resp, err := gw.client.Get(healthURL)
		if err != nil {
			services[name] = map[string]interface{}{
				"status": "unhealthy",
				"error":  err.Error(),
			}
			continue
		}
		defer resp.Body.Close()

		if resp.StatusCode == 200 {
			services[name] = map[string]interface{}{
				"status": "healthy",
				"url":    service.URL,
			}
		} else {
			services[name] = map[string]interface{}{
				"status": "unhealthy",
				"code":   resp.StatusCode,
			}
		}
	}

	response.Success(c, map[string]interface{}{
		"gateway":   "healthy",
		"services":  services,
		"timestamp": time.Now(),
	}, "网关健康检查")
}

// ListServices 列出所有注册的服务
func (gw *Gateway) ListServices(c *gin.Context) {
	services := make([]ServiceConfig, 0, len(gw.services))
	for _, service := range gw.services {
		services = append(services, *service)
	}

	response.Success(c, services, "服务列表获取成功")
}

// Welcome 欢迎页面
func (gw *Gateway) Welcome(c *gin.Context) {
	response.Success(c, map[string]interface{}{
		"message":      "Welcome to Gin E-commerce Microservices!",
		"version":      "2.0.0",
		"services":     len(gw.services),
		"frontend_url": "/shop",
		"api_features": []string{
			"用户管理",
			"商品管理",
			"购物车管理",
			"订单管理",
			"状态监控",
		},
		"gateway_features": []string{
			"智能路由",
			"负载均衡",
			"健康检查",
			"服务发现",
			"跨域支持",
		},
	}, "欢迎使用电商微服务平台")
}

// GetAPIRoutes 获取API路由信息
func (gw *Gateway) GetAPIRoutes(c *gin.Context) {
	routes := map[string]interface{}{
		"user_service": map[string][]string{
			"GET":    {"/api/v1/users", "/api/v1/users/{id}"},
			"POST":   {"/api/v1/users"},
			"PUT":    {"/api/v1/users/{id}"},
			"DELETE": {"/api/v1/users/{id}"},
		},
		"product_service": map[string][]string{
			"GET":    {"/api/v1/products", "/api/v1/products/{id}"},
			"POST":   {"/api/v1/products"},
			"PUT":    {"/api/v1/products/{id}"},
			"DELETE": {"/api/v1/products/{id}"},
		},
		"cart_service": map[string][]string{
			"GET":    {"/api/v1/cart", "/api/v1/cart/summary"},
			"POST":   {"/api/v1/cart/items"},
			"PUT":    {"/api/v1/cart/items/{item_id}"},
			"DELETE": {"/api/v1/cart", "/api/v1/cart/items/{item_id}"},
		},
		"order_service": map[string][]string{
			"GET":  {"/api/v1/orders", "/api/v1/orders/{id}", "/api/v1/orders/summary"},
			"POST": {"/api/v1/orders"},
			"PUT":  {"/api/v1/orders/{id}/status", "/api/v1/orders/{id}/cancel"},
		},
	}

	response.Success(c, routes, "API路由信息")
}

func main() {
	// 创建网关实例
	gateway := NewGateway()

	// 注册微服务
	userServiceHost := os.Getenv("USER_SERVICE_HOST")
	if userServiceHost == "" {
		userServiceHost = "localhost"
	}
	userServicePort := os.Getenv("USER_SERVICE_PORT")
	if userServicePort == "" {
		userServicePort = "8081"
	}

	productServiceHost := os.Getenv("PRODUCT_SERVICE_HOST")
	if productServiceHost == "" {
		productServiceHost = "localhost"
	}
	productServicePort := os.Getenv("PRODUCT_SERVICE_PORT")
	if productServicePort == "" {
		productServicePort = "8082"
	}

	cartServiceHost := os.Getenv("CART_SERVICE_HOST")
	if cartServiceHost == "" {
		cartServiceHost = "localhost"
	}
	cartServicePort := os.Getenv("CART_SERVICE_PORT")
	if cartServicePort == "" {
		cartServicePort = "8083"
	}

	orderServiceHost := os.Getenv("ORDER_SERVICE_HOST")
	if orderServiceHost == "" {
		orderServiceHost = "localhost"
	}
	orderServicePort := os.Getenv("ORDER_SERVICE_PORT")
	if orderServicePort == "" {
		orderServicePort = "8084"
	}

	gateway.RegisterService("user-service", userServiceHost, userServicePort)
	gateway.RegisterService("product-service", productServiceHost, productServicePort)
	gateway.RegisterService("cart-service", cartServiceHost, cartServicePort)
	gateway.RegisterService("order-service", orderServiceHost, orderServicePort)

	// 创建路由
	r := gin.New()
	r.Use(gin.Logger())
	r.Use(gin.Recovery())

	// 添加CORS支持
	r.Use(func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	})

	// 静态文件服务（前端）
	r.Static("/frontend", "./frontend")
	r.StaticFile("/shop", "./frontend/index.html")

	// 根路径重定向到商城
	r.GET("/", func(c *gin.Context) {
		c.Redirect(http.StatusFound, "/shop")
	})

	// Swagger文档
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// 网关管理路由
	r.GET("/gateway", gateway.Welcome)
	r.GET("/health", gateway.HealthCheck)
	r.GET("/services", gateway.ListServices)
	r.GET("/api-routes", gateway.GetAPIRoutes)

	// API代理路由
	api := r.Group("/api/v1")
	{
		// 用户服务代理
		api.Any("/users", gateway.ProxyRequest)
		api.Any("/users/*path", gateway.ProxyRequest)

		// 产品服务代理
		api.Any("/products", gateway.ProxyRequest)
		api.Any("/products/*path", gateway.ProxyRequest)

		// 购物车服务代理
		api.Any("/cart", gateway.ProxyRequest)
		api.Any("/cart/*path", gateway.ProxyRequest)

		// 订单服务代理
		api.Any("/orders", gateway.ProxyRequest)
		api.Any("/orders/*path", gateway.ProxyRequest)
	}

	// 404处理
	r.NoRoute(func(c *gin.Context) {
		response.NotFound(c, "页面不存在")
	})

	// 获取端口
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080" // 网关默认端口
	}

	log.Printf("🚀 电商微服务API网关启动在端口: %s", port)
	log.Printf("📋 注册的微服务:")
	for name, service := range gateway.services {
		log.Printf("  ✅ %s: %s", name, service.URL)
	}
	log.Printf("🌐 商城地址: http://localhost:%s/shop", port)
	log.Printf("📖 API文档: http://localhost:%s/api-routes", port)
	log.Printf("🔧 网关管理: http://localhost:%s/gateway", port)

	r.Run(":" + port)
}
