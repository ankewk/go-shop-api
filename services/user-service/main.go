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

// UserService 用户服务
type UserService struct {
	db *gorm.DB
}

// GetUsers 获取用户列表
func (s *UserService) GetUsers(c *gin.Context) {
	var users []models.User

	// 简单的分页查询
	page := 1
	pageSize := 10
	offset := (page - 1) * pageSize

	result := s.db.Offset(offset).Limit(pageSize).Find(&users)
	if result.Error != nil {
		response.InternalServerError(c, "获取用户列表失败", result.Error.Error())
		return
	}

	var total int64
	s.db.Model(&models.User{}).Count(&total)

	pagination := models.PaginationInfo{
		Page:     page,
		PageSize: pageSize,
		Total:    total,
	}

	response.SuccessWithPagination(c, users, pagination, "用户列表获取成功")
}

// CreateUser 创建用户
func (s *UserService) CreateUser(c *gin.Context) {
	var req models.CreateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "请求参数格式错误", err.Error())
		return
	}

	// 检查邮箱是否已存在
	var existingUser models.User
	if err := s.db.Where("email = ?", req.Email).First(&existingUser).Error; err == nil {
		response.BadRequest(c, "邮箱已被注册", "")
		return
	}

	user := &models.User{
		Name:   req.Name,
		Email:  req.Email,
		Phone:  req.Phone,
		Status: 1,
	}

	if err := s.db.Create(user).Error; err != nil {
		response.InternalServerError(c, "创建用户失败", err.Error())
		return
	}

	response.Created(c, user, "用户创建成功")
}

// GetUser 获取单个用户
func (s *UserService) GetUser(c *gin.Context) {
	id := c.Param("id")
	var user models.User

	if err := s.db.First(&user, id).Error; err != nil {
		response.NotFound(c, "用户不存在")
		return
	}

	response.Success(c, user, "用户信息获取成功")
}

// HealthCheck 健康检查
func (s *UserService) HealthCheck(c *gin.Context) {
	response.Success(c, map[string]interface{}{
		"service": "user-service",
		"status":  "healthy",
		"port":    os.Getenv("PORT"),
	}, "用户服务健康检查通过")
}

func main() {
	// 初始化数据库
	db, err := config.InitDatabase()
	if err != nil {
		log.Fatalf("数据库连接失败: %v", err)
	}

	// 自动迁移
	db.AutoMigrate(&models.User{})

	// 创建服务实例
	userService := &UserService{db: db}

	// 创建路由
	r := gin.New()
	r.Use(gin.Logger())
	r.Use(gin.Recovery())

	// 暂时移除Swagger文档，待环境稳定后添加
	// r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// 健康检查
	r.GET("/health", userService.HealthCheck)

	// 用户相关路由
	api := r.Group("/api/v1")
	{
		api.GET("/users", userService.GetUsers)
		api.POST("/users", userService.CreateUser)
		api.GET("/users/:id", userService.GetUser)
	}

	// 获取端口
	port := os.Getenv("PORT")
	if port == "" {
		port = "8085" // 用户服务默认端口
	}

	log.Printf("用户服务启动在端口: %s", port)
	r.Run(":" + port)
}
