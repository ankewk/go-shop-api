package repository

import (
	"fmt"
	"go-shop-api/middleware"
	"go-shop-api/services/order-service/config"
	"go-shop-api/services/order-service/models"

	"gorm.io/gorm"
)

// OrderShardingRepository 订单分表仓储
type OrderShardingRepository struct {
	db                *gorm.DB
	sharding          *middleware.ShardingMiddleware
	orderConfig       *middleware.ShardingConfig
	orderItemConfig   *middleware.ShardingConfig
	statusConfig      *middleware.ShardingConfig
}

// NewOrderShardingRepository 创建订单分表仓储
func NewOrderShardingRepository(db *gorm.DB) *OrderShardingRepository {
	return &OrderShardingRepository{
		db:              db,
		sharding:        middleware.NewShardingMiddleware(config.OrderShardingConfig),
		orderConfig:     config.OrderShardingConfig,
		orderItemConfig: config.OrderItemShardingConfig,
		statusConfig:    config.OrderStatusHistoryShardingConfig,
	}
}

// InitShardingTables 初始化所有分表
func (r *OrderShardingRepository) InitShardingTables() error {
	// 初始化订单分表
	if err := r.sharding.CreateAllShardTables(r.db, &models.Order{}); err != nil {
		return fmt.Errorf("failed to create order shard tables: %w", err)
	}

	// 初始化订单项分表
	orderItemSharding := middleware.NewShardingMiddleware(r.orderItemConfig)
	if err := orderItemSharding.CreateAllShardTables(r.db, &models.OrderItem{}); err != nil {
		return fmt.Errorf("failed to create order item shard tables: %w", err)
	}

	// 初始化订单状态历史分表
	statusSharding := middleware.NewShardingMiddleware(r.statusConfig)
	if err := statusSharding.CreateAllShardTables(r.db, &models.OrderStatusHistory{}); err != nil {
		return fmt.Errorf("failed to create order status history shard tables: %w", err)
	}

	return nil
}

// CreateOrder 创建订单（自动分表）
func (r *OrderShardingRepository) CreateOrder(order *models.Order) error {
	tableName := config.GetOrderTableName(order.UserID)
	return r.db.Table(tableName).Create(order).Error
}

// GetOrderByID 根据ID获取订单
func (r *OrderShardingRepository) GetOrderByID(orderID, userID uint) (*models.Order, error) {
	var order models.Order
	tableName := config.GetOrderTableName(userID)
	
	err := r.db.Table(tableName).First(&order, orderID).Error
	if err != nil {
		return nil, err
	}

	// 加载关联数据
	order.Items = []models.OrderItem{}
	order.StatusHistory = []models.OrderStatusHistory{}
	
	itemTableName := config.GetOrderItemTableName(orderID)
	r.db.Table(itemTableName).Where("order_id = ?", orderID).Find(&order.Items)
	
	statusTableName := config.GetOrderStatusHistoryTableName(orderID)
	r.db.Table(statusTableName).Where("order_id = ?", orderID).Order("created_at desc").Find(&order.StatusHistory)
	
	return &order, nil
}

// GetOrdersByUserID 获取用户的所有订单
func (r *OrderShardingRepository) GetOrdersByUserID(userID uint, params *models.OrderQueryParams) ([]models.Order, int64, error) {
	tableName := config.GetOrderTableName(userID)
	var orders []models.Order
	var total int64

	query := r.db.Table(tableName).Where("user_id = ?", userID)

	// 应用过滤条件
	if params.Status != nil && *params.Status != "" {
		query = query.Where("status = ?", *params.Status)
	}
	if params.StartDate != nil {
		query = query.Where("created_at >= ?", *params.StartDate)
	}
	if params.EndDate != nil {
		query = query.Where("created_at <= ?", *params.EndDate)
	}

	// 计算总数
	query.Count(&total)

	// 分页查询
	if params.Page <= 0 {
		params.Page = 1
	}
	if params.Limit <= 0 {
		params.Limit = 20
	}
	offset := (params.Page - 1) * params.Limit

	err := query.Order("created_at desc").Limit(params.Limit).Offset(offset).Find(&orders).Error
	if err != nil {
		return nil, 0, err
	}

	// 加载关联数据
	for i := range orders {
		orderID := orders[i].ID
		itemTableName := config.GetOrderItemTableName(orderID)
		statusTableName := config.GetOrderStatusHistoryTableName(orderID)
		
		r.db.Table(itemTableName).Where("order_id = ?", orderID).Find(&orders[i].Items)
		r.db.Table(statusTableName).Where("order_id = ?", orderID).Order("created_at desc").Find(&orders[i].StatusHistory)
	}

	return orders, total, nil
}

// UpdateOrderStatus 更新订单状态
func (r *OrderShardingRepository) UpdateOrderStatus(orderID, userID uint, status string, note string) error {
	tableName := config.GetOrderTableName(userID)
	
	// 更新订单状态
	err := r.db.Table(tableName).Where("id = ?", orderID).Update("status", status).Error
	if err != nil {
		return err
	}

	// 添加状态历史
	statusHistory := &models.OrderStatusHistory{
		OrderID: orderID,
		Status:  status,
		Note:    note,
	}
	
	statusTableName := config.GetOrderStatusHistoryTableName(orderID)
	return r.db.Table(statusTableName).Create(statusHistory).Error
}

// AddOrderItem 添加订单项
func (r *OrderShardingRepository) AddOrderItem(orderID, userID uint, item *models.OrderItem) error {
	item.OrderID = orderID
	itemTableName := config.GetOrderItemTableName(orderID)
	return r.db.Table(itemTableName).Create(item).Error
}

// GetOrderStatistics 获取订单统计（跨分表查询）
func (r *OrderShardingRepository) GetOrderStatistics(userID uint) (*models.OrderStatistics, error) {
	stats := &models.OrderStatistics{}
	tableName := config.GetOrderTableName(userID)
	
	// 总订单数
	err := r.db.Table(tableName).Where("user_id = ?", userID).Count(&stats.TotalOrders).Error
	if err != nil {
		return nil, err
	}

	// 总订单金额
	err = r.db.Table(tableName).Where("user_id = ?", userID).Select("COALESCE(SUM(total_amount), 0)").Scan(&stats.TotalAmount).Error
	if err != nil {
		return nil, err
	}

	// 待处理订单
	err = r.db.Table(tableName).Where("user_id = ? AND status = ?", userID, "pending").Count(&stats.PendingOrders).Error
	if err != nil {
		return nil, err
	}

	// 已完成订单
	err = r.db.Table(tableName).Where("user_id = ? AND status = ?", userID, "completed").Count(&stats.CompletedOrders).Error
	if err != nil {
		return nil, err
	}

	return stats, nil
}

// DeleteOrder 删除订单（软删除）
func (r *OrderShardingRepository) DeleteOrder(orderID, userID uint) error {
	tableName := config.GetOrderTableName(userID)
	return r.db.Table(tableName).Where("id = ?", orderID).Delete(&models.Order{}).Error
}