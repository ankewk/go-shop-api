package main

import (
	"log"
	"os"
	"strconv"

	_ "gin-project/services/cart-service/docs"
	"gin-project/shared/config"
	"gin-project/shared/models"
	"gin-project/shared/response"

	"github.com/gin-gonic/gin"
	ginSwagger "github.com/swaggo/gin-swagger"
	"gorm.io/gorm"
)

// CartService 购物车服务
type CartService struct {
	db *gorm.DB
}

// GetCart 获取用户购物车
func (s *CartService) GetCart(c *gin.Context) {
	userIDStr := c.Query("user_id")
	if userIDStr == "" {
		response.BadRequest(c, "用户ID不能为空", "")
		return
	}

	userID, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		response.BadRequest(c, "用户ID格式错误", err.Error())
		return
	}

	// 查找或创建购物车
	var cart models.Cart
	result := s.db.Where("user_id = ?", userID).Preload("Items.Product").First(&cart)
	if result.Error != nil {
		if result.Error == gorm.ErrRecordNotFound {
			// 创建新购物车
			cart = models.Cart{
				UserID: uint(userID),
				Items:  []models.CartItem{},
			}
			s.db.Create(&cart)
		} else {
			response.InternalServerError(c, "获取购物车失败", result.Error.Error())
			return
		}
	}

	// 计算总金额和商品数量
	s.calculateCartTotals(&cart)

	response.Success(c, cart, "购物车获取成功")
}

// AddToCart 添加商品到购物车
func (s *CartService) AddToCart(c *gin.Context) {
	userIDStr := c.Query("user_id")
	if userIDStr == "" {
		response.BadRequest(c, "用户ID不能为空", "")
		return
	}

	userID, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		response.BadRequest(c, "用户ID格式错误", err.Error())
		return
	}

	var req models.AddToCartRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "请求参数格式错误", err.Error())
		return
	}

	// 检查商品是否存在
	var product models.Product
	if err := s.db.First(&product, req.ProductID).Error; err != nil {
		response.NotFound(c, "商品不存在")
		return
	}

	// 检查库存
	if product.Stock < req.Quantity {
		response.BadRequest(c, "库存不足", "当前库存: "+strconv.Itoa(product.Stock))
		return
	}

	// 查找或创建购物车
	var cart models.Cart
	result := s.db.Where("user_id = ?", userID).First(&cart)
	if result.Error != nil {
		if result.Error == gorm.ErrRecordNotFound {
			cart = models.Cart{UserID: uint(userID)}
			s.db.Create(&cart)
		} else {
			response.InternalServerError(c, "获取购物车失败", result.Error.Error())
			return
		}
	}

	// 检查商品是否已在购物车中
	var cartItem models.CartItem
	itemResult := s.db.Where("cart_id = ? AND product_id = ?", cart.ID, req.ProductID).First(&cartItem)

	if itemResult.Error == gorm.ErrRecordNotFound {
		// 添加新商品
		cartItem = models.CartItem{
			CartID:    cart.ID,
			ProductID: req.ProductID,
			Quantity:  req.Quantity,
			Price:     product.Price,
		}
		s.db.Create(&cartItem)
	} else {
		// 更新数量
		cartItem.Quantity += req.Quantity
		s.db.Save(&cartItem)
	}

	// 重新加载购物车数据
	s.db.Where("user_id = ?", userID).Preload("Items.Product").First(&cart)
	s.calculateCartTotals(&cart)

	response.Success(c, cart, "商品添加成功")
}

// UpdateCartItem 更新购物车商品
func (s *CartService) UpdateCartItem(c *gin.Context) {
	userIDStr := c.Query("user_id")
	itemIDStr := c.Param("item_id")

	userID, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		response.BadRequest(c, "用户ID格式错误", err.Error())
		return
	}

	itemID, err := strconv.ParseUint(itemIDStr, 10, 32)
	if err != nil {
		response.BadRequest(c, "商品项ID格式错误", err.Error())
		return
	}

	var req models.UpdateCartItemRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "请求参数格式错误", err.Error())
		return
	}

	// 查找购物车项
	var cartItem models.CartItem
	result := s.db.Joins("JOIN carts ON cart_items.cart_id = carts.id").
		Where("cart_items.id = ? AND carts.user_id = ?", itemID, userID).
		First(&cartItem)

	if result.Error != nil {
		response.NotFound(c, "购物车项不存在")
		return
	}

	if req.Quantity == 0 {
		// 删除商品项
		s.db.Delete(&cartItem)
	} else {
		// 更新数量
		cartItem.Quantity = req.Quantity
		s.db.Save(&cartItem)
	}

	// 重新加载购物车数据
	var cart models.Cart
	s.db.Where("user_id = ?", userID).Preload("Items.Product").First(&cart)
	s.calculateCartTotals(&cart)

	response.Success(c, cart, "购物车更新成功")
}

// RemoveFromCart 从购物车删除商品
func (s *CartService) RemoveFromCart(c *gin.Context) {
	userIDStr := c.Query("user_id")
	itemIDStr := c.Param("item_id")

	userID, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		response.BadRequest(c, "用户ID格式错误", err.Error())
		return
	}

	itemID, err := strconv.ParseUint(itemIDStr, 10, 32)
	if err != nil {
		response.BadRequest(c, "商品项ID格式错误", err.Error())
		return
	}

	// 删除购物车项
	result := s.db.Exec("DELETE FROM cart_items WHERE id = ? AND cart_id IN (SELECT id FROM carts WHERE user_id = ?)", itemID, userID)
	if result.Error != nil {
		response.InternalServerError(c, "删除失败", result.Error.Error())
		return
	}

	if result.RowsAffected == 0 {
		response.NotFound(c, "购物车项不存在")
		return
	}

	response.Success(c, nil, "商品删除成功")
}

// ClearCart 清空购物车
func (s *CartService) ClearCart(c *gin.Context) {
	userIDStr := c.Query("user_id")
	userID, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		response.BadRequest(c, "用户ID格式错误", err.Error())
		return
	}

	// 删除购物车中的所有商品
	s.db.Exec("DELETE FROM cart_items WHERE cart_id IN (SELECT id FROM carts WHERE user_id = ?)", userID)

	response.Success(c, nil, "购物车已清空")
}

// GetCartSummary 获取购物车摘要
func (s *CartService) GetCartSummary(c *gin.Context) {
	userIDStr := c.Query("user_id")
	userID, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		response.BadRequest(c, "用户ID格式错误", err.Error())
		return
	}

	var summary models.CartSummary

	// 查询购物车摘要信息
	row := s.db.Raw(`
		SELECT 
			COALESCE(SUM(ci.quantity), 0) as item_count,
			COALESCE(SUM(ci.quantity * ci.price), 0) as total_amount,
			COUNT(ci.id) as unique_items
		FROM carts c 
		LEFT JOIN cart_items ci ON c.id = ci.cart_id 
		WHERE c.user_id = ?
	`, userID).Row()

	err = row.Scan(&summary.ItemCount, &summary.TotalAmount, &summary.UniqueItems)
	if err != nil {
		response.InternalServerError(c, "获取购物车摘要失败", err.Error())
		return
	}

	response.Success(c, summary, "购物车摘要获取成功")
}

// HealthCheck 健康检查
func (s *CartService) HealthCheck(c *gin.Context) {
	response.Success(c, map[string]interface{}{
		"service": "cart-service",
		"status":  "healthy",
		"port":    os.Getenv("PORT"),
	}, "购物车服务健康检查通过")
}

// calculateCartTotals 计算购物车总计
func (s *CartService) calculateCartTotals(cart *models.Cart) {
	cart.Total = 0
	cart.ItemCount = 0

	for i := range cart.Items {
		cart.Items[i].Total = cart.Items[i].Price * float64(cart.Items[i].Quantity)
		cart.Total += cart.Items[i].Total
		cart.ItemCount += cart.Items[i].Quantity
	}
}

func main() {
	// 初始化数据库
	db, err := config.InitDatabase()
	if err != nil {
		log.Fatalf("数据库连接失败: %v", err)
	}

	// 自动迁移
	db.AutoMigrate(&models.Cart{}, &models.CartItem{})

	// 创建服务实例
	cartService := &CartService{db: db}

	// 创建路由
	r := gin.New()
	r.Use(gin.Logger())
	r.Use(gin.Recovery())

	// Swagger文档
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// 健康检查
	r.GET("/health", cartService.HealthCheck)

	// 购物车相关路由
	api := r.Group("/api/v1")
	{
		api.GET("/cart", cartService.GetCart)                          // 获取购物车
		api.POST("/cart/items", cartService.AddToCart)                 // 添加商品到购物车
		api.PUT("/cart/items/:item_id", cartService.UpdateCartItem)    // 更新购物车商品
		api.DELETE("/cart/items/:item_id", cartService.RemoveFromCart) // 删除购物车商品
		api.DELETE("/cart", cartService.ClearCart)                     // 清空购物车
		api.GET("/cart/summary", cartService.GetCartSummary)           // 获取购物车摘要
	}

	// 获取端口
	port := os.Getenv("PORT")
	if port == "" {
		port = "8083" // 购物车服务默认端口
	}

	log.Printf("购物车服务启动在端口: %s", port)
	r.Run(":" + port)
}
