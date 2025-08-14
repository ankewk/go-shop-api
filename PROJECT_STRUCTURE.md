# 微服务架构电商项目结构

## 项目概述
这是一个基于微服务架构的电商系统，包含8个独立的微服务，每个服务负责特定的业务功能。

## 项目结构

```
go-shop-api/
├── services/                    # 微服务目录
│   ├── api-gateway/            # API网关服务 (端口: 8080)
│   │   ├── main.go
│   │   ├── Dockerfile
│   │   └── go.mod
│   ├── auth-service/           # 认证服务 (端口: 8081)
│   │   ├── main.go
│   │   ├── Dockerfile
│   │   └── go.mod
│   ├── user-service/           # 用户服务 (端口: 8082)
│   │   ├── main.go
│   │   ├── Dockerfile
│   │   └── go.mod
│   ├── product-service/        # 商品服务 (端口: 8083)
│   │   ├── main.go
│   │   ├── Dockerfile
│   │   └── go.mod
│   ├── order-service/          # 订单服务 (端口: 8084)
│   │   ├── main.go
│   │   ├── Dockerfile
│   │   └── go.mod
│   ├── cart-service/           # 购物车服务 (端口: 8085)
│   │   ├── main.go
│   │   ├── Dockerfile
│   │   └── go.mod
│   ├── payment-service/        # 支付服务 (端口: 8086)
│   │   ├── main.go
│   │   ├── Dockerfile
│   │   └── go.mod
│   └── notification-service/   # 通知服务 (端口: 8087)
│       ├── main.go
│       ├── Dockerfile
│       └── go.mod
├── config/                     # 配置文件
├── docker/                     # Docker相关配置
├── docs/                       # 文档目录
├── middleware/                 # 中间件
├── models/                     # 共享模型
├── response/                   # 响应封装
├── scripts/                    # 脚本文件
├── shared/                     # 共享资源
│   ├── config/
│   ├── models/
│   └── response/
├── quick-start.sh             # 快速启动脚本
├── start-all-microservices.sh # 启动所有微服务脚本
├── docker-compose.yml         # Docker Compose配置
├── go.mod                     # 根模块依赖
└── PROJECT_STRUCTURE.md       # 项目结构说明
```

## 微服务详情

### 1. API Gateway (8080)
- **功能**: 统一入口，路由分发，负载均衡
- **数据库**: gateway_db
- **依赖**: 所有其他微服务

### 2. Auth Service (8081)
- **功能**: 用户认证，JWT令牌管理
- **数据库**: auth_db
- **端口**: 8081

### 3. User Service (8082)
- **功能**: 用户信息管理，用户注册/登录
- **数据库**: user_db
- **端口**: 8082

### 4. Product Service (8083)
- **功能**: 商品管理，商品搜索，库存管理
- **数据库**: product_db
- **端口**: 8083

### 5. Order Service (8084)
- **功能**: 订单管理，订单状态跟踪
- **数据库**: order_db
- **端口**: 8084

### 6. Cart Service (8085)
- **功能**: 购物车管理，商品添加/删除
- **数据库**: cart_db
- **端口**: 8085

### 7. Payment Service (8086)
- **功能**: 支付处理，退款管理
- **数据库**: payment_db
- **端口**: 8086

### 8. Notification Service (8087)
- **功能**: 通知管理，消息推送
- **数据库**: notification_db
- **端口**: 8087

## 技术栈

- **后端框架**: Gin (Golang)
- **数据库**: PostgreSQL
- **容器化**: Docker & Docker Compose
- **API文档**: Swagger/OpenAPI
- **监控**: 预留接口

## 快速开始

### 1. 启动所有服务
```bash
# 使用Docker Compose启动所有服务
docker-compose up --build

# 或者使用脚本
./start-all-microservices.sh
```

### 2. 单独启动某个服务
```bash
# 进入服务目录
cd services/[service-name]

# 构建镜像
docker build -t [service-name] .

# 运行容器
docker run -p [port]:[port] [service-name]
```

### 3. 测试API
每个服务都提供了健康检查接口：
```bash
curl http://localhost:[port]/health
```

## 数据库配置

每个微服务都有独立的数据库实例，配置在docker-compose.yml中：
- **主机**: postgres-[service-name]
- **端口**: 5432
- **用户名**: [service]_user
- **密码**: [service]_password
- **数据库**: [service]_db

## API端点

### 通用端点格式
所有服务都遵循RESTful API设计：
- GET /api/[resource] - 获取列表
- GET /api/[resource]/{id} - 获取详情
- POST /api/[resource] - 创建
- PUT /api/[resource]/{id} - 更新
- DELETE /api/[resource]/{id} - 删除

## 开发指南

### 1. 添加新微服务
1. 在services/目录下创建新服务文件夹
2. 创建main.go, Dockerfile, go.mod文件
3. 在docker-compose.yml中添加服务配置
4. 更新PROJECT_STRUCTURE.md文档

### 2. 数据库迁移
使用GORM的AutoMigrate功能自动处理数据库迁移。

### 3. 环境变量
每个服务支持以下环境变量：
- PORT: 服务端口
- DATABASE_URL: 数据库连接字符串

## 监控和日志

- 每个服务都包含健康检查端点
- 使用Docker日志收集
- 预留Prometheus监控接口

## 扩展性

- 支持水平扩展：每个服务可以独立扩展
- 支持负载均衡：通过API Gateway实现
- 支持服务发现：预留接口
- 支持配置管理：通过环境变量