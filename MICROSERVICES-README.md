# Go Shop API - 微服务架构

## 架构概述

本项目采用微服务架构，每个服务都有独立的数据库和Redis实例，实现了真正的服务解耦。

## 服务列表

### 核心服务

| 服务名称 | 端口 | 数据库 | Redis | 描述 |
|----------|------|--------|--------|------|
| API Gateway | 8080 | - | redis-auth | 统一入口，路由分发 |
| Auth Service | 8081 | postgres-auth | redis-auth | 用户认证与授权 |
| User Service | 8082 | postgres-user | redis-user | 用户管理与档案 |
| Product Service | 8084 | postgres-product | redis-product | 商品管理与库存 |
| Order Service | 8083 | postgres-order | redis-order | 订单处理 |
| Cart Service | 8085 | postgres-cart | redis-cart | 购物车管理 |
| Payment Service | 8086 | postgres-payment | - | 支付处理 |
| Notification Service | 8087 | postgres-notification | - | 消息通知 |

## 数据库配置

### 独立数据库实例

每个服务都有独立的PostgreSQL数据库：

- **auth_db**: 认证服务数据库
  - 用户表、角色表、会话表
  - 端口: 5432

- **user_db**: 用户服务数据库
  - 用户档案、地址管理
  - 端口: 5433

- **product_db**: 商品服务数据库
  - 商品信息、分类、库存
  - 端口: 5434

- **order_db**: 订单服务数据库
  - 订单信息、订单项、状态历史
  - 端口: 5435

- **payment_db**: 支付服务数据库
  - 支付记录、退款信息
  - 端口: 5436

- **notification_db**: 通知服务数据库
  - 通知模板、发送记录
  - 端口: 5437

- **cart_db**: 购物车服务数据库
  - 购物车项、用户购物车
  - 端口: 5438

### 独立Redis实例

每个需要缓存的服务都有独立的Redis：

- **redis-auth**: 认证缓存 (端口: 6379)
- **redis-user**: 用户缓存 (端口: 6380)
- **redis-product**: 商品缓存 (端口: 6381)
- **redis-order**: 订单缓存 (端口: 6382)
- **redis-cart**: 购物车缓存 (端口: 6383)

## 快速开始

### 1. 启动所有服务

```bash
# 使用Docker Compose启动所有微服务
docker-compose -f docker-compose.microservices.yml up -d

# 查看服务状态
docker-compose -f docker-compose.microservices.yml ps
```

### 2. 初始化数据库

```bash
# 运行数据库初始化脚本
./init-microservices-db.sh
```

### 3. 测试服务

```bash
# 测试API Gateway
curl http://localhost:8080/health

# 测试认证服务
curl http://localhost:8081/health

# 测试商品服务
curl http://localhost:8084/products
```

## 数据流

```
客户端 → API Gateway → 具体服务 → 独立数据库
```

## 优势

1. **独立部署**: 每个服务可以独立部署和扩展
2. **故障隔离**: 一个服务故障不会影响其他服务
3. **技术多样性**: 每个服务可以使用最适合的技术栈
4. **独立扩展**: 可以根据需求独立扩展特定服务
5. **数据隔离**: 每个服务的数据完全隔离

## 监控和管理

### 查看日志

```bash
# 查看特定服务日志
docker-compose -f docker-compose.microservices.yml logs auth-service

# 实时查看所有日志
docker-compose -f docker-compose.microservices.yml logs -f
```

### 停止服务

```bash
# 停止所有服务
docker-compose -f docker-compose.microservices.yml down

# 停止并删除数据卷
docker-compose -f docker-compose.microservices.yml down -v
```

## 环境变量

每个服务的环境变量配置：

```bash
# 认证服务
AUTH_DB_HOST=postgres-auth
AUTH_DB_PORT=5432
AUTH_DB_USER=auth_user
AUTH_DB_PASSWORD=auth_pass
AUTH_DB_NAME=auth_db

# 用户服务
USER_DB_HOST=postgres-user
USER_DB_PORT=5432
USER_DB_USER=user_user
USER_DB_PASSWORD=user_pass
USER_DB_NAME=user_db

# 商品服务
PRODUCT_DB_HOST=postgres-product
PRODUCT_DB_PORT=5432
PRODUCT_DB_USER=product_user
PRODUCT_DB_PASSWORD=product_pass
PRODUCT_DB_NAME=product_db

# 订单服务
ORDER_DB_HOST=postgres-order
ORDER_DB_PORT=5432
ORDER_DB_USER=order_user
ORDER_DB_PASSWORD=order_pass
ORDER_DB_NAME=order_db
```