package routes

import (
	"gin-project/controllers"
	"gin-project/middleware"
	"gin-project/response"

	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/swaggo/files"
	"github.com/swaggo/gin-swagger"
)

// SetupRoutes 设置路由
func SetupRoutes(
	userController *controllers.UserController,
	healthController *controllers.HealthController,
	productController *controllers.ProductController,
) *gin.Engine {
	// 创建gin引擎
	r := gin.New()

	// 添加中间件
	r.Use(middleware.Logger())
	r.Use(middleware.Recovery())
	r.Use(middleware.CORS())

	// Swagger文档路由
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// 根路由
	// @Summary 欢迎页面
	// @Description 项目欢迎页面，显示基本信息
	// @Tags 系统管理
	// @Produce json
	// @Success 200 {object} models.APIResponse "欢迎信息"
	// @Router / [get]
	r.GET("/", func(c *gin.Context) {
		response.Success(c, map[string]interface{}{
			"message":     "Hello Gin with MVC Architecture!",
			"version":     "1.0.0",
			"status":      "running",
			"swagger_url": "/swagger/index.html",
		}, "欢迎使用Gin MVC项目")
	})

	// API路由组
	api := r.Group("/api/v1")
	{
		// 健康检查
		api.GET("/health", healthController.HealthCheck)

		// 用户相关路由
		userRoutes := api.Group("/users")
		{
			userRoutes.GET("", userController.GetUsers)          // 获取用户列表
			userRoutes.POST("", userController.CreateUser)       // 创建用户
			userRoutes.GET("/:id", userController.GetUserByID)   // 获取指定用户
			userRoutes.PUT("/:id", userController.UpdateUser)    // 更新用户
			userRoutes.DELETE("/:id", userController.DeleteUser) // 删除用户
		}

		// 产品相关路由
		productRoutes := api.Group("/products")
		{
			productRoutes.GET("", productController.GetProducts)          // 获取产品列表
			productRoutes.POST("", productController.CreateProduct)       // 创建产品
			productRoutes.GET("/:id", productController.GetProductByID)   // 获取指定产品
			productRoutes.PUT("/:id", productController.UpdateProduct)    // 更新产品
			productRoutes.DELETE("/:id", productController.DeleteProduct) // 删除产品
		}
	}

	// 404处理
	r.NoRoute(func(c *gin.Context) {
		response.NotFound(c, "请求的资源不存在")
	})

	// 405处理
	r.NoMethod(func(c *gin.Context) {
		response.Error(c, http.StatusMethodNotAllowed, "请求方法不被允许", "")
	})

	return r
}
