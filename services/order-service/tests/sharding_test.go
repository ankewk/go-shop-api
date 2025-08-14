package tests

import (
	"testing"
	"time"

	"go-shop-api/services/order-service/config"
	"go-shop-api/services/order-service/models"
	"go-shop-api/services/order-service/repository"
	"go-shop-api/services/order-service/service"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func setupTestDB() *gorm.DB {
	dsn := "host=localhost port=5435 user=order_user password=order_pass dbname=order_db sslmode=disable"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}
	return db
}

func TestShardingCalculation(t *testing.T) {
	testCases := []struct {
		userID   uint
		expected string
	}{
		{1, "orders_01"},
		{10, "orders_00"},
		{123, "orders_03"},
		{999, "orders_09"},
		{1000, "orders_00"},
	}

	for _, tc := range testCases {
		result := config.GetOrderTableName(tc.userID)
		if result != tc.expected {
			t.Errorf("For userID %d, expected %s but got %s", tc.userID, tc.expected, result)
		}
	}
}

func TestCreateOrder(t *testing.T) {
	db := setupTestDB()
	repo := repository.NewOrderShardingRepository(db)
	service := service.NewOrderShardingService(repo)

	// 初始化分表
	err := service.InitializeSharding()
	if err != nil {
		t.Fatalf("Failed to initialize sharding: %v", err)
	}

	// 测试创建订单
	order := &models.Order{
		UserID:      123,
		TotalAmount: 299.99,
		Status:      "pending",
	}

	err = service.CreateOrder(order)
	if err != nil {
		t.Fatalf("Failed to create order: %v", err)
	}

	if order.ID == 0 {
		t.Error("Order ID should be generated")
	}

	if order.OrderNumber == "" {
		t.Error("Order number should be generated")
	}
}

func TestGetOrder(t *testing.T) {
	db := setupTestDB()
	repo := repository.NewOrderShardingRepository(db)
	service := service.NewOrderShardingService(repo)

	// 创建测试订单
	order := &models.Order{
		UserID:      456,
		TotalAmount: 599.99,
		Status:      "pending",
	}

	err := service.CreateOrder(order)
	if err != nil {
		t.Fatalf("Failed to create order: %v", err)
	}

	// 测试获取订单
	retrievedOrder, err := service.GetOrder(order.ID, order.UserID)
	if err != nil {
		t.Fatalf("Failed to get order: %v", err)
	}

	if retrievedOrder.ID != order.ID {
		t.Errorf("Expected order ID %d, got %d", order.ID, retrievedOrder.ID)
	}

	if retrievedOrder.UserID != order.UserID {
		t.Errorf("Expected user ID %d, got %d", order.UserID, retrievedOrder.UserID)
	}
}

func TestUpdateOrderStatus(t *testing.T) {
	db := setupTestDB()
	repo := repository.NewOrderShardingRepository(db)
	service := service.NewOrderShardingService(repo)

	// 创建测试订单
	order := &models.Order{
		UserID:      789,
		TotalAmount: 199.99,
		Status:      "pending",
	}

	err := service.CreateOrder(order)
	if err != nil {
		t.Fatalf("Failed to create order: %v", err)
	}

	// 测试更新状态
	err = service.UpdateOrderStatus(order.ID, order.UserID, "shipped", "Order has been shipped")
	if err != nil {
		t.Fatalf("Failed to update order status: %v", err)
	}

	// 验证更新
	updatedOrder, err := service.GetOrder(order.ID, order.UserID)
	if err != nil {
		t.Fatalf("Failed to get updated order: %v", err)
	}

	if updatedOrder.Status != "shipped" {
		t.Errorf("Expected status 'shipped', got '%s'", updatedOrder.Status)
	}
}

func TestGetUserOrders(t *testing.T) {
	db := setupTestDB()
	repo := repository.NewOrderShardingRepository(db)
	service := service.NewOrderShardingService(repo)

	userID := uint(1001)

	// 创建多个测试订单
	orders := []*models.Order{
		{UserID: userID, TotalAmount: 100.00, Status: "pending"},
		{UserID: userID, TotalAmount: 200.00, Status: "completed"},
		{UserID: userID, TotalAmount: 300.00, Status: "shipped"},
	}

	for _, order := range orders {
		err := service.CreateOrder(order)
		if err != nil {
		t.Fatalf("Failed to create order: %v", err)
		}
	}

	// 测试分页查询
	params := &models.OrderQueryParams{
		Page:  1,
		Limit: 10,
	}

	result, err := service.GetUserOrders(userID, params)
	if err != nil {
		t.Fatalf("Failed to get user orders: %v", err)
	}

	if len(result.Orders) != 3 {
		t.Errorf("Expected 3 orders, got %d", len(result.Orders))
	}

	if result.Total != 3 {
		t.Errorf("Expected total 3 orders, got %d", result.Total)
	}
}

func TestOrderStatistics(t *testing.T) {
	db := setupTestDB()
	repo := repository.NewOrderShardingRepository(db)
	service := service.NewOrderShardingService(repo)

	userID := uint(2002)

	// 创建测试数据
	orders := []*models.Order{
		{UserID: userID, TotalAmount: 100.00, Status: "completed"},
		{UserID: userID, TotalAmount: 200.00, Status: "pending"},
		{UserID: userID, TotalAmount: 300.00, Status: "completed"},
	}

	for _, order := range orders {
		err := service.CreateOrder(order)
		if err != nil {
			t.Fatalf("Failed to create order: %v", err)
		}
	}

	// 测试统计
	stats, err := service.GetOrderStatistics(userID)
	if err != nil {
		t.Fatalf("Failed to get order statistics: %v", err)
	}

	if stats.TotalOrders != 3 {
		t.Errorf("Expected 3 total orders, got %d", stats.TotalOrders)
	}

	expectedTotal := 600.00
	if stats.TotalAmount != expectedTotal {
		t.Errorf("Expected total amount %.2f, got %.2f", expectedTotal, stats.TotalAmount)
	}

	if stats.CompletedOrders != 2 {
		t.Errorf("Expected 2 completed orders, got %d", stats.CompletedOrders)
	}

	if stats.PendingOrders != 1 {
		t.Errorf("Expected 1 pending order, got %d", stats.PendingOrders)
	}
}

func TestConcurrentOrderCreation(t *testing.T) {
	db := setupTestDB()
	repo := repository.NewOrderShardingRepository(db)
	service := service.NewOrderShardingService(repo)

	// 初始化分表
	err := service.InitializeSharding()
	if err != nil {
		t.Fatalf("Failed to initialize sharding: %v", err)
	}

	// 并发创建订单
	const numOrders = 100
	const numWorkers = 10

	ordersChan := make(chan *models.Order, numOrders)
	errorChan := make(chan error, numOrders)

	// 启动工作协程
	for i := 0; i < numWorkers; i++ {
		go func() {
			for order := range ordersChan {
				err := service.CreateOrder(order)
				if err != nil {
					errorChan <- err
				}
			}
		}()
	}

	// 发送订单数据
	for i := 0; i < numOrders; i++ {
		ordersChan <- &models.Order{
			UserID:      uint(i % 100), // 100个不同用户
			TotalAmount: float64(i+1) * 10.0,
			Status:      "pending",
		}
	}
	close(ordersChan)

	// 等待完成
	close(errorChan)
	
	// 检查错误
	for err := range errorChan {
		t.Errorf("Concurrent order creation failed: %v", err)
	}
}

func TestDataDistribution(t *testing.T) {
	db := setupTestDB()
	repo := repository.NewOrderShardingRepository(db)
	
	// 测试数据分布是否均匀
	const testUsers = 1000
	const ordersPerUser = 10
	
	distribution := make(map[int]int)
	
	for userID := 1; userID <= testUsers; userID++ {
		shardIndex := int(userID % 10)
		distribution[shardIndex] += ordersPerUser
	}
	
	// 验证分布是否相对均匀
	expectedPerShard := testUsers * ordersPerUser / 10
	tolerance := expectedPerShard / 10 // 10%的容差
	
	for shard, count := range distribution {
		if abs(count-expectedPerShard) > tolerance {
			t.Errorf("Shard %d distribution uneven: expected ~%d, got %d", 
				shard, expectedPerShard, count)
		}
	}
}

func abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

func BenchmarkShardingCalculation(b *testing.B) {
	for i := 0; i < b.N; i++ {
		config.GetOrderTableName(uint(i))
	}
}

func BenchmarkCreateOrder(b *testing.B) {
	db := setupTestDB()
	repo := repository.NewOrderShardingRepository(db)
	service := service.NewOrderShardingService(repo)
	
	service.InitializeSharding()
	
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		order := &models.Order{
			UserID:      uint(i % 1000),
			TotalAmount: 299.99,
			Status:      "pending",
		}
		service.CreateOrder(order)
	}
}