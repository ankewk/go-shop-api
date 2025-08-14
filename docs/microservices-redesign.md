# 🚀 Go Shop 微服务重新设计方案

## 📋 设计目标

1. **现代化架构** - 采用云原生设计模式
2. **高可用性** - 支持故障恢复和弹性伸缩
3. **可观测性** - 完整的监控、日志、链路追踪
4. **性能优化** - 缓存、异步处理、数据库优化
5. **安全增强** - JWT认证、API网关、限流熔断

## 🏗️ 新微服务架构图

```
┌─────────────────────────────────────────────────────────────┐
│                        API Gateway                          │
│                    (统一入口 + 认证授权)                      │
└─────────────────────┬───────────────────────────────────────┘
                      │
    ┌─────────────────┼─────────────────┐
    │                 │                 │
┌───▼───┐        ┌───▼───┐        ┌───▼───┐
│ Auth  │        │ User  │        │Order  │
│Service│        │Service│        │Service│
│:8081  │        │:8082  │        │:8083  │
└───┬───┘        └───┬───┘        └───┬───┘
    │                │                │
    │     ┌──────────┼──────────┐     │
    │     │          │          │     │
┌───▼───┐ ┌─▼───┐ ┌──▼───┐ ┌───▼───┐ ┌─▼───┐
│Product│ │Cart │ │Payment│ │Notification│ │Search│
│Service│ │Svc  │ │Service│ │   Service  │ │Service│
│:8084  │ │:8085│ │:8086  │ │    :8087   │ │:8088 │
└───────┘ └─────┘ └───────┘ └───────────┘ └─────┘
```

## 🔧 服务拆分策略

### 1. 认证授权服务 (auth-service)
**端口**: 8081  
**职责**: 用户认证、JWT令牌、权限管理

```go
// 服务接口设计
POST /api/v1/auth/login          // 用户登录
POST /api/v1/auth/register       // 用户注册
POST /api/v1/auth/refresh        // 刷新令牌
POST /api/v1/auth/logout         // 用户登出
GET  /api/v1/auth/validate       // 验证令牌
```

### 2. 用户管理服务 (user-service)
**端口**: 8082  
**职责**: 用户信息管理、个人资料、地址管理

```go
// 用户管理接口
GET    /api/v1/users/:id         // 获取用户信息
PUT    /api/v1/users/:id         // 更新用户信息
DELETE /api/v1/users/:id         // 删除用户
GET    /api/v1/users/:id/profile  // 获取用户档案
PUT    /api/v1/users/:id/profile  // 更新用户档案
```

### 3. 订单管理服务 (order-service)
**端口**: 8083  
**职责**: 订单创建、状态管理、订单历史

```go
// 订单管理接口
POST   /api/v1/orders            // 创建订单
GET    /api/v1/orders/:id        // 获取订单详情
PUT    /api/v1/orders/:id/status // 更新订单状态
GET    /api/v1/orders/user/:userId // 获取用户订单列表
DELETE /api/v1/orders/:id        // 取消订单
```

### 4. 商品管理服务 (product-service)
**端口**: 8084  
**职责**: 商品信息、库存管理、商品分类

```go
// 商品管理接口
GET    /api/v1/products          // 获取商品列表
GET    /api/v1/products/:id      // 获取商品详情
POST   /api/v1/products          // 创建商品 (管理员)
PUT    /api/v1/products/:id      // 更新商品 (管理员)
DELETE /api/v1/products/:id      // 删除商品 (管理员)
```

### 5. 购物车服务 (cart-service)
**端口**: 8085  
**职责**: 购物车管理、商品添加删除、数量更新

```go
// 购物车接口
GET    /api/v1/cart              // 获取购物车
POST   /api/v1/cart/items        // 添加商品到购物车
PUT    /api/v1/cart/items/:itemId // 更新商品数量
DELETE /api/v1/cart/items/:itemId // 从购物车删除商品
DELETE /api/v1/cart              // 清空购物车
```

### 6. 支付服务 (payment-service)
**端口**: 8086  
**职责**: 支付处理、退款、支付状态查询

```go
// 支付接口
POST /api/v1/payments             // 创建支付订单
GET  /api/v1/payments/:id        // 查询支付状态
POST /api/v1/payments/:id/refund  // 申请退款
POST /api/v1/payments/webhook     // 支付回调
```

### 7. 通知服务 (notification-service)
**端口**: 8087  
**职责**: 消息通知、邮件发送、短信通知

```go
// 通知接口
POST /api/v1/notifications        // 发送通知
GET  /api/v1/notifications/:id   // 获取通知详情
PUT  /api/v1/notifications/:id/read // 标记已读
```

### 8. 搜索服务 (search-service)
**端口**: 8088  
**职责**: 商品搜索、全文搜索、搜索建议

```go
// 搜索接口
GET /api/v1/search/products       // 搜索商品
GET /api/v1/search/suggestions    // 搜索建议
GET /api/v1/search/filters        // 搜索筛选
```

## 🎯 API网关增强

### 功能特性
- **统一入口**: 所有外部请求通过网关
- **认证授权**: JWT令牌验证和权限检查
- **限流熔断**: 防止系统过载
- **负载均衡**: 服务实例负载分发
- **API版本控制**: 支持多版本API
- **请求/响应转换**: 数据格式转换

### 路由配置示例
```yaml
# 网关路由配置
routes:
  - path: /api/v1/auth
    service: auth-service
    strip_prefix: true
    
  - path: /api/v1/users
    service: user-service
    middlewares:
      - auth
      - rate_limit
      
  - path: /api/v1/orders
    service: order-service
    middlewares:
      - auth
      - rate_limit
```

## 🗄️ 数据库设计

### 分库分表策略
```
auth_db      # 认证相关数据
├── users
├── roles
└── permissions

user_db      # 用户相关数据
├── user_profiles
├── user_addresses
└── user_preferences

order_db     # 订单相关数据
├── orders
├── order_items
└── order_status_history

product_db   # 商品相关数据
├── products
├── categories
├── inventory
└── product_images
```

### 缓存策略
- **Redis集群**: 分布式缓存
- **缓存预热**: 启动时加载热点数据
- **缓存穿透**: 布隆过滤器防止缓存穿透
- **缓存雪崩**: 随机过期时间防止雪崩

## 📊 监控和可观测性

### 1. 指标监控 (Prometheus)
```yaml
# 业务指标
- http_requests_total
- http_request_duration_seconds
- user_registration_total
- order_creation_total
- payment_success_rate

# 系统指标
- cpu_usage_percent
- memory_usage_bytes
- disk_io_operations
- network_io_bytes
```

### 2. 链路追踪 (Jaeger)
```go
// 分布式追踪示例
span := tracer.StartSpan("create-order")
defer span.Finish()

span.SetTag("user.id", userID)
span.SetTag("order.total", totalAmount)
```

### 3. 日志聚合 (ELK Stack)
```json
{
  "timestamp": "2024-01-01T10:00:00Z",
  "level": "info",
  "service": "order-service",
  "trace_id": "abc123",
  "span_id": "def456",
  "message": "订单创建成功",
  "metadata": {
    "order_id": "ORD-2024-001",
    "user_id": 12345,
    "amount": 299.99
  }
}
```

## 🔐 安全设计

### 1. 认证授权
- **JWT令牌**: 无状态认证
- **OAuth2.0**: 第三方登录
- **RBAC**: 基于角色的权限控制
- **API密钥**: 服务端到服务端认证

### 2. 数据安全
- **数据加密**: 敏感数据加密存储
- **传输加密**: HTTPS/TLS 1.3
- **SQL注入防护**: 参数化查询
- **XSS防护**: 输入验证和输出编码

### 3. 网络安全
- **API限流**: 基于IP和用户限流
- **DDoS防护**: 流量清洗
- **CORS配置**: 跨域请求控制
- **请求签名**: 防止重放攻击

## 🚀 部署策略

### 1. 容器化部署
```yaml
# Docker Compose 配置
version: '3.8'
services:
  auth-service:
    image: go-shop/auth-service:latest
    ports:
      - "8081:8081"
    environment:
      - DB_HOST=auth-db
      - REDIS_URL=redis://redis:6379
    depends_on:
      - auth-db
      - redis
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8081/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### 2. Kubernetes部署
```yaml
# K8s Deployment示例
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: order-service
  template:
    metadata:
      labels:
        app: order-service
    spec:
      containers:
      - name: order-service
        image: go-shop/order-service:latest
        ports:
        - containerPort: 8083
        env:
        - name: DB_HOST
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: host
```

### 3. 蓝绿部署
```bash
# 蓝绿部署脚本
#!/bin/bash
# 部署新版本
docker-compose -f docker-compose.green.yml up -d

# 健康检查
./health-check.sh green

# 切换流量
./switch-traffic.sh green

# 停止旧版本
docker-compose -f docker-compose.blue.yml down
```

## 🔄 事件驱动架构

### 事件总线设计
```go
// 事件定义
type OrderCreatedEvent struct {
    OrderID    string    `json:"order_id"`
    UserID     int64     `json:"user_id"`
    Total      float64   `json:"total"`
    Items      []OrderItem `json:"items"`
    CreatedAt  time.Time `json:"created_at"`
}

// 事件发布
func (s *OrderService) publishOrderCreated(event OrderCreatedEvent) {
    s.eventBus.Publish("order.created", event)
}

// 事件订阅
func (s *NotificationService) handleOrderCreated(event OrderCreatedEvent) {
    // 发送订单确认邮件
    s.sendOrderConfirmationEmail(event.UserID, event.OrderID)
}
```

### 事件流
```
用户下单 → OrderCreated事件 → 库存检查 → PaymentPending事件 → 支付完成 → OrderPaid事件 → 发货通知
```

## 📈 性能优化

### 1. 数据库优化
- **读写分离**: 主从数据库配置
- **连接池**: 数据库连接池优化
- **索引优化**: 关键字段索引
- **查询优化**: 避免N+1查询问题

### 2. 缓存策略
- **多级缓存**: L1(应用) + L2(Redis) + L3(CDN)
- **缓存预热**: 热点数据预加载
- **缓存更新**: 消息队列异步更新
- **缓存一致性**: 最终一致性保证

### 3. 异步处理
- **消息队列**: RabbitMQ/Kafka
- **任务调度**: 分布式任务调度
- **批量处理**: 减少数据库访问
- **并发控制**: 协程池管理

## 🔧 开发工具链

### 1. 代码生成
```bash
# 使用go-swagger生成代码
swagger generate server -f swagger.yml -A order-service

# 使用protobuf生成gRPC代码
protoc --go_out=. --go-grpc_out=. order.proto
```

### 2. 测试框架
```go
// 集成测试示例
func TestCreateOrder(t *testing.T) {
    // 使用testcontainers进行集成测试
    postgres, err := testcontainers.GenericContainer(ctx, testcontainers.ContainerRequest{
        Image:        "postgres:13",
        ExposedPorts: []string{"5432/tcp"},
        Env: map[string]string{
            "POSTGRES_PASSWORD": "password",
        },
    })
    // ... 测试逻辑
}
```

### 3. CI/CD流水线
```yaml
# GitHub Actions配置
name: Build and Deploy
on:
  push:
    branches: [main]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-go@v4
      with:
        go-version: '1.21'
    - run: go test ./...
    - run: go build -v .
```

## 📊 迁移计划

### 阶段1: 基础服务拆分 (Week 1-2)
- [ ] 认证服务独立部署
- [ ] 用户服务重构
- [ ] API网关实现

### 阶段2: 核心业务拆分 (Week 3-4)
- [ ] 订单服务独立
- [ ] 商品服务独立
- [ ] 购物车服务独立

### 阶段3: 增强服务 (Week 5-6)
- [ ] 支付服务
- [ ] 通知服务
- [ ] 搜索服务

### 阶段4: 监控和优化 (Week 7-8)
- [ ] 监控系统集成
- [ ] 性能优化
- [ ] 安全加固

## 🎯 技术选型

| 组件 | 当前 | 新方案 | 理由 |
|------|------|--------|------|
| **API网关** | 单体路由 | Kong/Envoy | 企业级网关 |
| **服务发现** | 静态配置 | Consul/Eureka | 动态服务发现 |
| **配置管理** | 环境变量 | Consul/Nacos | 集中配置管理 |
| **消息队列** | 无 | RabbitMQ/Kafka | 异步处理 |
| **缓存** | 无 | Redis Cluster | 高性能缓存 |
| **监控** | 基础日志 | Prometheus+Grafana | 完整监控体系 |
| **链路追踪** | 无 | Jaeger/Zipkin | 分布式追踪 |
| **容器编排** | Docker | Kubernetes | 容器编排 |

这个重新设计方案将传统单体应用转变为现代化的云原生微服务架构，提供更好的可扩展性、可维护性和可观测性。