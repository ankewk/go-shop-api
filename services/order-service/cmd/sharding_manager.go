package main

import (
	"fmt"
	"log"
	"os"

	"go-shop-api/services/order-service/config"
	"go-shop-api/services/order-service/models"
	"go-shop-api/services/order-service/repository"
	"go-shop-api/services/order-service/service"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run sharding_manager.go [init|migrate|stats|test]")
		return
	}

	// 数据库连接
	dsn := "host=localhost port=5435 user=order_user password=order_pass dbname=order_db sslmode=disable"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	repo := repository.NewOrderShardingRepository(db)
	service := service.NewOrderShardingService(repo)

	command := os.Args[1]

	switch command {
	case "init":
		initShardingTables(service)
	case "migrate":
		migrateData(service)
	case "stats":
		showStats(service)
	case "test":
		runTests(service)
	default:
		fmt.Println("Unknown command:", command)
	}
}

func initShardingTables(service *service.OrderShardingService) {
	fmt.Println("Initializing sharding tables...")
	
	err := service.InitializeSharding()
	if err != nil {
		log.Fatal("Failed to initialize sharding tables:", err)
	}
	
	fmt.Println("Sharding tables initialized successfully!")
}

func migrateData(service *service.OrderShardingService) {
	fmt.Println("Migrating existing data to sharding tables...")
	
	err := service.MigrateExistingData()
	if err != nil {
		log.Fatal("Failed to migrate data:", err)
	}
	
	fmt.Println("Data migration completed!")
}

func showStats(service *service.OrderShardingService) {
	fmt.Println("Sharding Statistics:")
	
	distribution, err := service.ValidateShardDistribution()
	if err != nil {
		log.Fatal("Failed to get distribution:", err)
	}
	
	total := int64(0)
	for shard, count := range distribution {
		fmt.Printf("Shard %02d: %d records\n", shard, count)
		total += count
	}
	
	fmt.Printf("Total: %d records\n", total)
	
	// 显示分布情况
	fmt.Println("\nDistribution Analysis:")
	for shard, count := range distribution {
		percentage := float64(count) / float64(total) * 100
		fmt.Printf("Shard %02d: %.2f%%\n", shard, percentage)
	}
}

func runTests(service *service.OrderShardingService) {
	fmt.Println("Running sharding tests...")
	
	// 测试创建订单
	order := &models.Order{
		UserID:      123,
		TotalAmount: 299.99,
		Status:      "pending",
	}
	
	err := service.CreateOrder(order)
	if err != nil {
		log.Fatal("Failed to create order:", err)
	}
	
	fmt.Printf("Created order: ID=%d, OrderNumber=%s, UserID=%d\n", order.ID, order.OrderNumber, order.UserID)
	
	// 测试获取订单
	retrievedOrder, err := service.GetOrder(order.ID, order.UserID)
	if err != nil {
		log.Fatal("Failed to get order:", err)
	}
	
	fmt.Printf("Retrieved order: ID=%d, TotalAmount=%.2f\n", retrievedOrder.ID, retrievedOrder.TotalAmount)
	
	// 测试更新状态
	err = service.UpdateOrderStatus(order.ID, order.UserID, "processing", "Payment received")
	if err != nil {
		log.Fatal("Failed to update order status:", err)
	}
	
	fmt.Println("Order status updated successfully!")
	
	// 测试获取统计
	stats, err := service.GetOrderStatistics(order.UserID)
	if err != nil {
		log.Fatal("Failed to get statistics:", err)
	}
	
	fmt.Printf("Statistics - TotalOrders: %d, TotalAmount: %.2f\n", stats.TotalOrders, stats.TotalAmount)
	
	fmt.Println("All tests passed!")
}