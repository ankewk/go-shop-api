# 🚀 Go Shop 微服务架构

基于现代云原生技术栈重新设计的电商微服务系统。

## 🏗️ 架构概览

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

## 🎯 服务列表

| 服务 | 端口 | 描述 | 状态 |
|------|------|------|------|
| **API Gateway** | 8080 | 统一入口、路由、认证、限流 | ✅ |
| **Auth Service** | 8081 | 用户认证、JWT令牌、权限管理 | ✅ |
| **User Service** | 8082 | 用户信息、档案、地址管理 | ✅ |
| **Order Service** | 8083 | 订单创建、状态管理、历史 | ✅ |
| **Product Service** | 8084 | 商品信息、库存、分类 | ✅ |
| **Cart Service** | 8085 | 购物车管理、商品操作 | ✅ |
| **Payment Service** | 8086 | 支付处理、退款、状态查询 | ✅ |
| **Notification Service** | 8087 | 消息通知、邮件、短信 | ✅ |
| **Search Service** | 8088 | 商品搜索、全文搜索、建议 | ✅ |

## 🚀 快速开始

### 1. 环境要求
- Docker & Docker Compose
- Go 1.21+
- PostgreSQL 13+
- Redis 7+

### 2. 启动服务

```bash
# 启动开发环境
./start-microservices.sh dev

# 启动测试环境
./start-microservices.sh test

# 启动生产环境
./start-microservices.sh prod

# 查看帮助
./start-microservices.sh --help
```

### 3. 验证服务

```bash
# 健康检查
./start-microservices.sh --health

# 查看日志
./start-microservices.sh --logs
```

## 📡 API 接口

### 认证相关
```bash
# 用户注册
POST http://localhost:8080/api/v1/auth/register
{
  "username": "testuser",
  "email": "test@example.com",
  "password": "password123"
}

# 用户登录
POST http://localhost:8080/api/v1/auth/login
{
  "username": "testuser",
  "password": "password123"
}

# 验证令牌
POST http://localhost:8080/api/v1/auth/validate
{
  "token": "your-jwt-token"
}
```

### 用户管理
```bash
# 获取用户信息
GET http://localhost:8080/api/v1/users/1

# 更新用户信息
PUT http://localhost:8080/api/v1/users/1
{
  "first_name": "John",
  "last_name": "Doe",
  "phone": "+1234567890"
}

# 获取用户地址
GET http://localhost:8080/api/v1/users/1/addresses

# 添加用户地址
POST http://localhost:8080/api/v1/users/1/addresses
{
  "type": "shipping",
  "name": "John Doe",
  "phone": "+1234567890",
  "address": "123 Main St",
  "city": "New York",
  "state": "NY",
  "zip_code": "10001",
  "country": "USA"
}
```

### 商品管理
```bash
# 获取商品列表
GET http://localhost:8080/api/v1/products

# 获取商品详情
GET http://localhost:8080/api/v1/products/1

# 搜索商品
GET http://localhost:8080/api/v1/search?query=iPhone&category=Electronics
```

### 购物车
```bash
# 获取购物车
GET http://localhost:8080/api/v1/cart

# 添加商品到购物车
POST http://localhost:8080/api/v1/cart/items
{
  "product_id": 1,
  "quantity": 2
}

# 更新商品数量
PUT http://localhost:8080/api/v1/cart/items/1
{
  "quantity": 3
}

# 删除商品
DELETE http://localhost:8080/api/v1/cart/items/1
```

### 订单管理
```bash
# 创建订单
POST http://localhost:8080/api/v1/orders
{
  "items": [
    {"product_id": 1, "quantity": 2},
    {"product_id": 2, "quantity": 1}
  ],
  "shipping_address_id": 1,
  "billing_address_id": 1
}

# 获取订单详情
GET http://localhost:8080/api/v1/orders/1

# 获取用户订单
GET http://localhost:8080/api/v1/orders/user/1
```

### 支付处理
```bash
# 创建支付
POST http://localhost:8080/api/v1/payments
{
  "order_id": 1,
  "payment_method": "credit_card",
  "amount": 299.99
}

# 查询支付状态
GET http://localhost:8080/api/v1/payments/1
```

## 🐳 Docker 管理

### 常用命令
```bash
# 启动所有服务
docker-compose -f docker-compose.microservices.yml up -d

# 停止所有服务
docker-compose -f docker-compose.microservices.yml down

# 查看日志
docker-compose -f docker-compose.microservices.yml logs -f

# 重新构建
docker-compose -f docker-compose.microservices.yml build --no-cache

# 查看服务状态
docker-compose -f docker-compose.microservices.yml ps
```

### 数据卷管理
```bash
# 查看卷
docker volume ls

# 删除卷
docker volume rm go-shop_postgres_data go-shop_redis_data

# 清理所有数据
docker-compose -f docker-compose.microservices.yml down -v
```

## 🔧 开发环境

### 本地开发
```bash
# 启动基础设施
docker-compose -f docker-compose.microservices.yml up -d postgres redis elasticsearch rabbitmq

# 启动单个服务
cd services-new/auth-service
go run main.go
```

### 环境变量
创建 `.env` 文件：
```bash
# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=password

# Redis配置
REDIS_URL=localhost:6379

# JWT配置
JWT_SECRET=your-secret-key
JWT_EXPIRY=24h

# 服务发现
AUTH_SERVICE_URL=localhost:8081
USER_SERVICE_URL=localhost:8082
ORDER_SERVICE_URL=localhost:8083
# ... 其他服务地址
```

## 📊 监控和可观测性

### 监控面板
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)
- **RabbitMQ**: http://localhost:15672 (admin/admin)

### 关键指标
- HTTP请求总数和延迟
- 数据库连接和查询性能
- Redis缓存命中率
- 消息队列处理速度
- 服务健康状态

### 日志聚合
使用 ELK Stack (Elasticsearch + Logstash + Kibana) 进行日志聚合和分析。

## 🔐 安全特性

- **JWT认证**: 无状态认证机制
- **API限流**: 防止DDoS攻击
- **输入验证**: 防止SQL注入和XSS
- **HTTPS**: 传输加密
- **CORS**: 跨域请求控制
- **RBAC**: 基于角色的权限控制

## 🚀 部署策略

### 开发部署
```bash
# 使用Docker Compose
docker-compose -f docker-compose.microservices.yml up -d
```

### Kubernetes部署
```bash
# 应用配置
kubectl apply -f k8s/

# 检查状态
kubectl get pods -n go-shop
```

### 蓝绿部署
```bash
# 部署新版本
docker-compose -f docker-compose.green.yml up -d

# 健康检查
./health-check.sh green

# 切换流量
./switch-traffic.sh green

# 停止旧版本
docker-compose -f docker-compose.blue.yml down
```

## 🧪 测试

### 单元测试
```bash
cd services-new/auth-service
go test ./...
```

### 集成测试
```bash
cd tests/integration
go test ./...
```

### 性能测试
```bash
# 使用Apache Bench
ab -n 1000 -c 10 http://localhost:8080/api/v1/products

# 使用wrk
wrk -t12 -c400 -d30s http://localhost:8080/api/v1/products
```

## 📚 文档

- [微服务设计文档](docs/microservices-redesign.md)
- [API文档](docs/api.md)
- [部署指南](docs/deployment.md)
- [监控指南](docs/monitoring.md)

## 🤝 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🆘 支持

- 创建 [GitHub Issue](https://github.com/yourusername/go-shop-api/issues)
- 查看 [Wiki](https://github.com/yourusername/go-shop-api/wiki)
- 加入 [Discord](https://discord.gg/go-shop)

## 🔄 更新日志

### v2.0.0 (2024-01-01)
- ✨ 全新的微服务架构
- 🔐 增强的安全特性
- 📊 完整的监控体系
- 🐳 Docker化部署
- 🚀 Kubernetes支持
- 📡 事件驱动架构

### v1.0.0 (2023-12-01)
- 🎯 初始版本
- 🏗️ 单体架构
- 🔐 基础认证
- 📦 商品管理