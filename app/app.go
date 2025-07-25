package app

import (
	"log"

	"gin-project/config"
	"gin-project/controllers"
	"gin-project/models"
	"gin-project/repositories"
	"gin-project/routes"
	"gin-project/services"

	"github.com/gin-gonic/gin"
)

// App 应用程序结构
type App struct {
	Router *gin.Engine
}

// Initialize 初始化应用程序
func (a *App) Initialize() {
	// 初始化数据库
	config.InitDatabase()

	// 自动迁移数据库表
	err := config.DB.AutoMigrate(&models.User{}, &models.Product{})
	if err != nil {
		log.Fatalf("数据库迁移失败: %v", err)
	}

	// 依赖注入
	a.setupDependencies()
}

// setupDependencies 设置依赖注入
func (a *App) setupDependencies() {
	// 创建仓储层
	userRepo := repositories.NewUserRepository(config.DB)
	productRepo := repositories.NewProductRepository(config.DB)

	// 创建服务层
	userService := services.NewUserService(userRepo)
	productService := services.NewProductService(productRepo)

	// 创建控制器层
	userController := controllers.NewUserController(userService)
	healthController := controllers.NewHealthController()
	productController := controllers.NewProductController(productService)

	// 设置路由
	a.Router = routes.SetupRoutes(userController, healthController, productController)
}

// Run 运行应用程序
func (a *App) Run(addr string) {
	log.Printf("服务器启动在: %s", addr)
	log.Fatal(a.Router.Run(addr))
}
