package config

import (
	"fmt"
	"go-shop-api/middleware"
)

// OrderShardingConfig 订单分表配置
var OrderShardingConfig = &middleware.ShardingConfig{
	TablePrefix: "orders",
	ShardCount:  10, // 10个分表
	ShardKey:    "user_id", // 按用户ID分表
}

// OrderItemShardingConfig 订单项分表配置
var OrderItemShardingConfig = &middleware.ShardingConfig{
	TablePrefix: "order_items",
	ShardCount:  10, // 与订单表保持一致
	ShardKey:    "order_id",
}

// OrderStatusHistoryShardingConfig 订单状态历史分表配置
var OrderStatusHistoryShardingConfig = &middleware.ShardingConfig{
	TablePrefix: "order_status_history",
	ShardCount:  10,
	ShardKey:    "order_id",
}

// GetOrderShardIndex 获取订单分表索引
func GetOrderShardIndex(userID uint) int {
	sharding := middleware.NewShardingMiddleware(OrderShardingConfig)
	tableName := sharding.GetShardTable(userID)
	
	// 从表名中提取索引
	var index int
	fmt.Sscanf(tableName, "orders_%02d", &index)
	return index
}

// GetOrderTableName 获取订单表名
func GetOrderTableName(userID uint) string {
	sharding := middleware.NewShardingMiddleware(OrderShardingConfig)
	return sharding.GetShardTable(userID)
}

// GetOrderItemTableName 获取订单项表名
func GetOrderItemTableName(orderID uint) string {
	sharding := middleware.NewShardingMiddleware(OrderItemShardingConfig)
	return sharding.GetShardTable(orderID)
}

// GetOrderStatusHistoryTableName 获取订单状态历史表名
func GetOrderStatusHistoryTableName(orderID uint) string {
	sharding := middleware.NewShardingMiddleware(OrderStatusHistoryShardingConfig)
	return sharding.GetShardTable(orderID)
}