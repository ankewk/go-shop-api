package service

import (
	"fmt"
	"go-shop-api/services/order-service/models"
	"go-shop-api/services/order-service/repository"
	"math/rand"
	"time"
)

// OrderShardingService 订单分表服务
type OrderShardingService struct {
	repo *repository.OrderShardingRepository
}

// NewOrderShardingService 创建订单分表服务
func NewOrderShardingService(repo *repository.OrderShardingRepository) *OrderShardingService {
	return &OrderShardingService{
		repo: repo,
	}
}

// InitializeSharding 初始化分表
func (s *OrderShardingService) InitializeSharding() error {
	return s.repo.InitShardingTables()
}

// CreateOrder 创建订单
func (s *OrderShardingService) CreateOrder(order *models.Order) error {
	// 生成订单号
	order.OrderNumber = s.generateOrderNumber()
	
	// 设置默认状态
	if order.Status == "" {
		order.Status = "pending"
	}
	
	// 设置创建时间
	order.CreatedAt = time.Now()
	order.UpdatedAt = time.Now()
	
	return s.repo.CreateOrder(order)
}

// GetOrder 获取订单详情
func (s *OrderShardingService) GetOrder(orderID, userID uint) (*models.Order, error) {
	return s.repo.GetOrderByID(orderID, userID)
}

// GetUserOrders 获取用户订单列表
func (s *OrderShardingService) GetUserOrders(userID uint, params *models.OrderQueryParams) (*models.OrderListResponse, error) {
	orders, total, err := s.repo.GetOrdersByUserID(userID, params)
	if err != nil {
		return nil, err
	}

	return &models.OrderListResponse{
		Orders: orders,
		Total:  total,
		Page:   params.Page,
		Limit:  params.Limit,
	}, nil
}

// UpdateOrderStatus 更新订单状态
func (s *OrderShardingService) UpdateOrderStatus(orderID, userID uint, status string, note string) error {
	return s.repo.UpdateOrderStatus(orderID, userID, status, note)
}

// AddOrderItem 添加订单项
func (s *OrderShardingService) AddOrderItem(orderID, userID uint, item *models.OrderItem) error {
	return s.repo.AddOrderItem(orderID, userID, item)
}

// GetOrderStatistics 获取订单统计
func (s *OrderShardingService) GetOrderStatistics(userID uint) (*models.OrderStatistics, error) {
	return s.repo.GetOrderStatistics(userID)
}

// DeleteOrder 删除订单
func (s *OrderShardingService) DeleteOrder(orderID, userID uint) error {
	return s.repo.DeleteOrder(orderID, userID)
}

// generateOrderNumber 生成订单号
func (s *OrderShardingService) generateOrderNumber() string {
	// 格式: ORD + 年月日 + 6位随机数
	now := time.Now()
	dateStr := now.Format("20060102")
	randomNum := rand.Intn(999999)
	return fmt.Sprintf("ORD%s%06d", dateStr, randomNum)
}

// MigrateExistingData 迁移现有数据到分表（批量操作）
func (s *OrderShardingService) MigrateExistingData() error {
	// 这里可以实现从旧表迁移数据到分表的逻辑
	// 由于涉及大量数据，建议使用批量处理和事务
	
	// TODO: 实现数据迁移逻辑
	return nil
}

// ValidateShardDistribution 验证分表数据分布
func (s *OrderShardingService) ValidateShardDistribution() (map[int]int64, error) {
	// 统计每个分表的数据量
	distribution := make(map[int]int64)
	
	for i := 0; i < 10; i++ {
		tableName := fmt.Sprintf("orders_%02d", i)
		var count int64
		
		err := s.repo.GetDB().Table(tableName).Count(&count).Error
		if err != nil {
			return nil, err
		}
		
		distribution[i] = count
	}
	
	return distribution, nil
}

// OrderListResponse 订单列表响应
type OrderListResponse struct {
	Orders []*models.Order `json:"orders"`
	Total  int64           `json:"total"`
	Page   int             `json:"page"`
	Limit  int             `json:"limit"`
}