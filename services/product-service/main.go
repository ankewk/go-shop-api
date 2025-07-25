package main

import (
	"log"
	"os"

	"gin-project/shared/config"
	"gin-project/shared/models"
	"gin-project/shared/response"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// ProductService 产品服务
type ProductService struct {
	db *gorm.DB
}

// GetProducts 获取产品列表
func (s *ProductService) GetProducts(c *gin.Context) {
	var products []models.Product

	// 简单的分页查询
	page := 1
	pageSize := 10
	offset := (page - 1) * pageSize

	result := s.db.Offset(offset).Limit(pageSize).Find(&products)
	if result.Error != nil {
		response.InternalServerError(c, "获取产品列表失败", result.Error.Error())
		return
	}

	var total int64
	s.db.Model(&models.Product{}).Count(&total)

	pagination := models.PaginationInfo{
		Page:     page,
		PageSize: pageSize,
		Total:    total,
	}

	response.SuccessWithPagination(c, products, pagination, "产品列表获取成功")
}

// CreateProduct 创建产品
func (s *ProductService) CreateProduct(c *gin.Context) {
	var req models.CreateProductRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "请求参数格式错误", err.Error())
		return
	}

	product := &models.Product{
		Name:        req.Name,
		Description: req.Description,
		Price:       req.Price,
		Stock:       req.Stock,
		Category:    req.Category,
		Status:      1,
	}

	if err := s.db.Create(product).Error; err != nil {
		response.InternalServerError(c, "创建产品失败", err.Error())
		return
	}

	response.Created(c, product, "产品创建成功")
}

// GetProduct 获取单个产品
func (s *ProductService) GetProduct(c *gin.Context) {
	id := c.Param("id")
	var product models.Product

	if err := s.db.First(&product, id).Error; err != nil {
		response.NotFound(c, "产品不存在")
		return
	}

	response.Success(c, product, "产品信息获取成功")
}

// HealthCheck 健康检查
func (s *ProductService) HealthCheck(c *gin.Context) {
	response.Success(c, map[string]interface{}{
		"service": "product-service",
		"status":  "healthy",
		"port":    os.Getenv("PORT"),
	}, "产品服务健康检查通过")
}

func main() {
	// 初始化数据库
	db, err := config.InitDatabase()
	if err != nil {
		log.Fatalf("数据库连接失败: %v", err)
	}

	// 自动迁移
	db.AutoMigrate(&models.Product{})

	// 创建服务实例
	productService := &ProductService{db: db}

	// 创建路由
	r := gin.New()
	r.Use(gin.Logger())
	r.Use(gin.Recovery())

	// 健康检查
	r.GET("/health", productService.HealthCheck)

	// 产品相关路由
	api := r.Group("/api/v1")
	{
		api.GET("/products", productService.GetProducts)
		api.POST("/products", productService.CreateProduct)
		api.GET("/products/:id", productService.GetProduct)
	}

	// 获取端口
	port := os.Getenv("PORT")
	if port == "" {
		port = "8082" // 产品服务默认端口
	}

	log.Printf("产品服务启动在端口: %s", port)
	r.Run(":" + port)
}
