# 订单分表使用指南

## 概述

本项目实现了基于用户ID的订单数据分表功能，将订单数据分布到10个独立的表中，以提高查询性能和数据管理效率。

## 分表结构

### 分表规则
- **分表数量**: 10个表（orders_00 到 orders_09）
- **分表策略**: 基于用户ID取模运算（user_id % 10）
- **关联表**: 订单项和订单状态历史也使用相同的分表策略

### 表结构

#### 订单分表
- `orders_00` ~ `orders_09`: 订单主表
- `order_items_00` ~ `order_items_09`: 订单项表
- `order_status_history_00` ~ `order_status_history_09`: 订单状态历史表

#### 视图
- `all_orders`: 所有订单分表的联合视图
- `all_order_items`: 所有订单项分表的联合视图
- `all_order_status_history`: 所有订单状态历史分表的联合视图

## 使用方法

### 1. 初始化分表

```bash
# 使用SQL脚本初始化
cd services/order-service
psql -h localhost -U order_user -d order_db -f scripts/init_sharding_tables.sql

# 使用Go程序初始化
go run cmd/sharding_manager.go init
```

### 2. 查看分表统计

```bash
go run cmd/sharding_manager.go stats
```

### 3. 运行测试

```bash
go run cmd/sharding_manager.go test
```

### 4. 数据迁移（从旧表到新分表）

```bash
go run cmd/sharding_manager.go migrate
```

## API使用示例

### 创建订单

```go
import (
    "go-shop-api/services/order-service/models"
    "go-shop-api/services/order-service/service"
)

// 创建订单服务
service := service.NewOrderShardingService(repository.NewOrderShardingRepository(db))

// 创建订单
order := &models.Order{
    UserID:      12345, // 根据此值计算分表
    TotalAmount: 299.99,
    Status:      "pending",
}

err := service.CreateOrder(order)
```

### 查询订单

```go
// 根据用户ID查询订单
orders, total, err := service.GetUserOrders(12345, &models.OrderQueryParams{
    Page:  1,
    Limit: 20,
})

// 根据订单ID查询单个订单
order, err := service.GetOrder(orderID, userID)
```

### 更新订单状态

```go
err := service.UpdateOrderStatus(orderID, userID, "shipped", "Order has been shipped")
```

## 分表查询原理

### 计算分表索引

```go
// 获取分表索引
shardIndex := userID % 10

// 对应的表名
tableName := fmt.Sprintf("orders_%02d", shardIndex)
```

### 查询优化

1. **按用户查询**: 直接定位到对应的分表
2. **按订单查询**: 通过订单ID反推用户ID，再定位分表
3. **跨分表查询**: 使用联合视图或并行查询

## 性能优势

### 查询性能提升
- **单表数据量减少**: 每个分表只包含1/10的数据
- **索引效率提升**: 更小的数据集意味着更快的索引查找
- **并发能力提升**: 多个分表可以并行处理查询

### 数据管理优势
- **独立维护**: 每个分表可以独立进行VACUUM、ANALYZE等操作
- **灵活扩展**: 可以单独对某个分表进行扩容或优化
- **故障隔离**: 单个分表问题不会影响其他分表

## 注意事项

### 1. 分表键选择
- **用户ID**作为分表键，确保同一用户的订单都在同一个分表中
- 避免跨分表的事务操作

### 2. 查询限制
- **避免跨分表JOIN**: 跨分表的JOIN操作性能较差
- **避免全局排序**: 跨分表的全局排序需要额外处理

### 3. 数据迁移
- **批量迁移**: 大量数据迁移建议使用批量处理
- **验证数据**: 迁移后需要验证数据完整性

### 4. 监控指标
- **分表数据分布**: 监控各分表的数据量是否均衡
- **查询性能**: 监控各分表的查询响应时间
- **存储空间**: 监控各分表的存储使用情况

## 监控和调试

### 查看分表分布
```sql
-- 查看每个分表的数据量
SELECT 'orders_00' as table_name, COUNT(*) as count FROM orders_00
UNION ALL SELECT 'orders_01', COUNT(*) FROM orders_01
UNION ALL SELECT 'orders_02', COUNT(*) FROM orders_02
-- ... 继续其他分表
ORDER BY table_name;
```

### 验证分表正确性
```sql
-- 验证用户ID 12345应该存储在哪个分表
SELECT 12345 % 10 as expected_shard;
-- 结果应该是5，对应orders_05表
```

### 性能测试
```bash
# 使用内置的性能测试工具
go test -bench=. -benchmem
```

## 故障排查

### 常见问题

1. **数据分布不均**: 检查用户ID的分布情况
2. **查询超时**: 检查分表索引和查询计划
3. **数据丢失**: 验证分表规则和查询逻辑

### 调试工具

```go
// 调试分表计算
fmt.Printf("UserID: %d -> Shard: %d\n", userID, userID%10)
fmt.Printf("Table: %s\n", config.GetOrderTableName(userID))
```

## 扩展建议

### 水平扩展
- **增加分表数量**: 当单表数据量过大时，可以增加分表数量
- **分库分表**: 当单库压力过大时，可以进一步分库

### 垂直扩展
- **读写分离**: 分表可以结合读写分离提高性能
- **缓存层**: 在分表基础上增加Redis缓存层

## 最佳实践

1. **选择合适的分表键**: 确保数据分布均匀
2. **避免跨分表操作**: 设计业务逻辑时考虑分表限制
3. **定期监控**: 监控分表数据分布和性能指标
4. **备份策略**: 为每个分表制定独立的备份策略