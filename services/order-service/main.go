package main

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"time"

	_ "gin-project/services/order-service/docs"
	"gin-project/shared/config"
	"gin-project/shared/models"
	"gin-project/shared/response"

	"github.com/gin-gonic/gin"
	ginSwagger "github.com/swaggo/gin-swagger"
	"gorm.io/gorm"
)

// OrderService 订单服务
type OrderService struct {
	db *gorm.DB
}

// CreateOrder 创建订单（从购物车结算）
func (s *OrderService) CreateOrder(c *gin.Context) {
	var req models.CreateOrderRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "请求参数格式错误", err.Error())
		return
	}

	// 验证用户是否存在
	var user models.User
	if err := s.db.First(&user, req.UserID).Error; err != nil {
		response.NotFound(c, "用户不存在")
		return
	}

	// 获取用户购物车
	var cart models.Cart
	if err := s.db.Where("user_id = ?", req.UserID).Preload("Items.Product").First(&cart).Error; err != nil {
		response.BadRequest(c, "购物车为空或不存在", "")
		return
	}

	if len(cart.Items) == 0 {
		response.BadRequest(c, "购物车为空，无法创建订单", "")
		return
	}

	// 开启事务
	tx := s.db.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// 生成订单号
	orderNo := fmt.Sprintf("ORD%s%03d", time.Now().Format("20060102150405"), req.UserID%1000)

	// 创建订单
	var totalAmount float64
	for _, item := range cart.Items {
		// 检查库存
		if item.Product.Stock < item.Quantity {
			tx.Rollback()
			response.BadRequest(c, fmt.Sprintf("商品 %s 库存不足", item.Product.Name),
				fmt.Sprintf("需要 %d 件，库存仅 %d 件", item.Quantity, item.Product.Stock))
			return
		}
		totalAmount += item.Price * float64(item.Quantity)
	}

	order := models.Order{
		OrderNo:       orderNo,
		UserID:        req.UserID,
		TotalAmount:   totalAmount,
		Status:        models.OrderStatusPending,
		PaymentMethod: req.PaymentMethod,
		ShippingAddr:  req.ShippingAddress,
		ContactPhone:  req.ContactPhone,
		ContactName:   req.ContactName,
		Remark:        req.Remark,
	}

	if err := tx.Create(&order).Error; err != nil {
		tx.Rollback()
		response.InternalServerError(c, "创建订单失败", err.Error())
		return
	}

	// 创建订单项并扣减库存
	for _, cartItem := range cart.Items {
		orderItem := models.OrderItem{
			OrderID:   order.ID,
			ProductID: cartItem.ProductID,
			Quantity:  cartItem.Quantity,
			Price:     cartItem.Price,
			Total:     cartItem.Price * float64(cartItem.Quantity),
		}

		if err := tx.Create(&orderItem).Error; err != nil {
			tx.Rollback()
			response.InternalServerError(c, "创建订单项失败", err.Error())
			return
		}

		// 扣减库存
		if err := tx.Model(&models.Product{}).Where("id = ?", cartItem.ProductID).
			Update("stock", gorm.Expr("stock - ?", cartItem.Quantity)).Error; err != nil {
			tx.Rollback()
			response.InternalServerError(c, "扣减库存失败", err.Error())
			return
		}
	}

	// 清空购物车
	if err := tx.Where("cart_id = ?", cart.ID).Delete(&models.CartItem{}).Error; err != nil {
		tx.Rollback()
		response.InternalServerError(c, "清空购物车失败", err.Error())
		return
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		response.InternalServerError(c, "提交事务失败", err.Error())
		return
	}

	// 重新加载订单信息
	s.db.Where("id = ?", order.ID).Preload("Items.Product").Preload("User").First(&order)

	response.Created(c, order, "订单创建成功")
}

// GetOrders 获取订单列表
func (s *OrderService) GetOrders(c *gin.Context) {
	userIDStr := c.Query("user_id")
	statusStr := c.Query("status")
	pageStr := c.DefaultQuery("page", "1")
	pageSizeStr := c.DefaultQuery("page_size", "10")

	page, _ := strconv.Atoi(pageStr)
	pageSize, _ := strconv.Atoi(pageSizeStr)
	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 10
	}

	query := s.db.Model(&models.Order{}).Preload("Items.Product").Preload("User")

	// 用户筛选
	if userIDStr != "" {
		if userID, err := strconv.ParseUint(userIDStr, 10, 32); err == nil {
			query = query.Where("user_id = ?", userID)
		}
	}

	// 状态筛选
	if statusStr != "" {
		query = query.Where("status = ?", statusStr)
	}

	// 计算总数
	var total int64
	query.Count(&total)

	// 分页查询
	var orders []models.Order
	offset := (page - 1) * pageSize
	if err := query.Offset(offset).Limit(pageSize).Order("created_at desc").Find(&orders).Error; err != nil {
		response.InternalServerError(c, "获取订单列表失败", err.Error())
		return
	}

	pagination := models.PaginationInfo{
		Page:     page,
		PageSize: pageSize,
		Total:    total,
	}

	c.JSON(200, gin.H{
		"code":       200,
		"message":    "订单列表获取成功",
		"data":       orders,
		"pagination": pagination,
	})
}

// GetOrder 获取单个订单
func (s *OrderService) GetOrder(c *gin.Context) {
	orderID := c.Param("id")
	userIDStr := c.Query("user_id")

	var order models.Order
	query := s.db.Preload("Items.Product").Preload("User")

	// 如果提供了用户ID，只查询该用户的订单
	if userIDStr != "" {
		if userID, err := strconv.ParseUint(userIDStr, 10, 32); err == nil {
			query = query.Where("user_id = ?", userID)
		}
	}

	if err := query.First(&order, orderID).Error; err != nil {
		response.NotFound(c, "订单不存在")
		return
	}

	response.Success(c, order, "订单信息获取成功")
}

// UpdateOrderStatus 更新订单状态
func (s *OrderService) UpdateOrderStatus(c *gin.Context) {
	orderID := c.Param("id")

	var req models.UpdateOrderStatusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "请求参数格式错误", err.Error())
		return
	}

	var order models.Order
	if err := s.db.First(&order, orderID).Error; err != nil {
		response.NotFound(c, "订单不存在")
		return
	}

	// 更新订单状态
	now := time.Now()
	updates := map[string]interface{}{
		"status": req.Status,
	}

	// 根据状态更新相应的时间字段
	switch req.Status {
	case models.OrderStatusPaid:
		updates["paid_at"] = &now
	case models.OrderStatusShipped:
		updates["shipped_at"] = &now
	case models.OrderStatusDelivered:
		updates["delivered_at"] = &now
	}

	if req.Remark != "" {
		updates["remark"] = req.Remark
	}

	if err := s.db.Model(&order).Updates(updates).Error; err != nil {
		response.InternalServerError(c, "更新订单状态失败", err.Error())
		return
	}

	// 重新加载订单信息
	s.db.Preload("Items.Product").Preload("User").First(&order, orderID)

	response.Success(c, order, "订单状态更新成功")
}

// CancelOrder 取消订单
func (s *OrderService) CancelOrder(c *gin.Context) {
	orderID := c.Param("id")
	userIDStr := c.Query("user_id")

	var order models.Order
	query := s.db.Preload("Items.Product")

	// 如果提供了用户ID，只允许取消该用户的订单
	if userIDStr != "" {
		if userID, err := strconv.ParseUint(userIDStr, 10, 32); err == nil {
			query = query.Where("user_id = ?", userID)
		}
	}

	if err := query.First(&order, orderID).Error; err != nil {
		response.NotFound(c, "订单不存在")
		return
	}

	// 只有待支付状态的订单可以取消
	if order.Status != models.OrderStatusPending {
		response.BadRequest(c, "只有待支付订单可以取消", "")
		return
	}

	// 开启事务
	tx := s.db.Begin()

	// 更新订单状态
	if err := tx.Model(&order).Update("status", models.OrderStatusCancelled).Error; err != nil {
		tx.Rollback()
		response.InternalServerError(c, "取消订单失败", err.Error())
		return
	}

	// 恢复库存
	for _, item := range order.Items {
		if err := tx.Model(&models.Product{}).Where("id = ?", item.ProductID).
			Update("stock", gorm.Expr("stock + ?", item.Quantity)).Error; err != nil {
			tx.Rollback()
			response.InternalServerError(c, "恢复库存失败", err.Error())
			return
		}
	}

	tx.Commit()

	response.Success(c, nil, "订单取消成功")
}

// GetOrderSummary 获取订单统计
func (s *OrderService) GetOrderSummary(c *gin.Context) {
	userIDStr := c.Query("user_id")

	var summary models.OrderSummary

	baseQuery := s.db.Model(&models.Order{})
	if userIDStr != "" {
		if userID, err := strconv.ParseUint(userIDStr, 10, 32); err == nil {
			baseQuery = baseQuery.Where("user_id = ?", userID)
		}
	}

	// 总订单数和总金额
	baseQuery.Select("COUNT(*) as total_orders, COALESCE(SUM(total_amount), 0) as total_amount").
		Row().Scan(&summary.TotalOrders, &summary.TotalAmount)

	// 各状态订单数
	baseQuery.Where("status = ?", models.OrderStatusPending).Count(&summary.PendingOrders)
	baseQuery.Where("status = ?", models.OrderStatusPaid).Count(&summary.PaidOrders)
	baseQuery.Where("status = ?", models.OrderStatusShipped).Count(&summary.ShippedOrders)

	// 今日订单数和金额
	today := time.Now().Format("2006-01-02")
	baseQuery.Where("DATE(created_at) = ?", today).
		Select("COUNT(*) as today_orders, COALESCE(SUM(total_amount), 0) as today_amount").
		Row().Scan(&summary.TodayOrders, &summary.TodayAmount)

	response.Success(c, summary, "订单统计获取成功")
}

// HealthCheck 健康检查
func (s *OrderService) HealthCheck(c *gin.Context) {
	response.Success(c, map[string]interface{}{
		"service": "order-service",
		"status":  "healthy",
		"port":    os.Getenv("PORT"),
	}, "订单服务健康检查通过")
}

func main() {
	// 初始化数据库
	db, err := config.InitDatabase()
	if err != nil {
		log.Fatalf("数据库连接失败: %v", err)
	}

	// 自动迁移
	db.AutoMigrate(&models.Order{}, &models.OrderItem{})

	// 创建服务实例
	orderService := &OrderService{db: db}

	// 创建路由
	r := gin.New()
	r.Use(gin.Logger())
	r.Use(gin.Recovery())

	// Swagger文档
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// 健康检查
	r.GET("/health", orderService.HealthCheck)

	// 订单相关路由
	api := r.Group("/api/v1")
	{
		api.POST("/orders", orderService.CreateOrder)                 // 创建订单
		api.GET("/orders", orderService.GetOrders)                    // 获取订单列表
		api.GET("/orders/:id", orderService.GetOrder)                 // 获取单个订单
		api.PUT("/orders/:id/status", orderService.UpdateOrderStatus) // 更新订单状态
		api.PUT("/orders/:id/cancel", orderService.CancelOrder)       // 取消订单
		api.GET("/orders/summary", orderService.GetOrderSummary)      // 获取订单统计
	}

	// 获取端口
	port := os.Getenv("PORT")
	if port == "" {
		port = "8084" // 订单服务默认端口
	}

	log.Printf("订单服务启动在端口: %s", port)
	r.Run(":" + port)
}
