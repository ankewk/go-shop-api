# Go Shop 微服务 Swagger 文档指南

本文档介绍如何使用和访问 Go Shop 微服务平台的 Swagger API 文档。

## 📖 Swagger 文档访问地址

### 通过 Docker 微服务访问（推荐）

启动微服务后，可以通过以下地址访问各服务的 Swagger 文档：

| 服务名称 | Swagger 地址 | 端口 | 描述 |
|---------|-------------|------|------|
| **API 网关** | http://localhost:8080/swagger/index.html | 8080 | 🌐 统一API文档入口 |
| 用户服务 | http://localhost:8085/swagger/index.html | 8085 | 👥 用户管理API |
| 产品服务 | http://localhost:8082/swagger/index.html | 8082 | 📦 产品管理API |
| 购物车服务 | http://localhost:8083/swagger/index.html | 8083 | 🛒 购物车API |
| 订单服务 | http://localhost:8084/swagger/index.html | 8084 | 📋 订单管理API |

### 直接访问（开发模式）

如果直接启动Go服务（非Docker），访问地址相同。

## 🚀 快速开始

### 1. 启动微服务
```bash
# 启动所有Docker微服务
docker-microservices-start.cmd

# 或者使用docker-compose
docker-compose -f docker-compose.microservices.yml up -d --build
```

### 2. 访问API网关文档
打开浏览器访问：http://localhost:8080/swagger/index.html

### 3. 测试API
在Swagger界面中：
1. 选择要测试的API接口
2. 点击 "Try it out" 按钮
3. 填写必要的参数
4. 点击 "Execute" 执行请求
5. 查看响应结果

## 📋 API 接口分类

### 🌐 API 网关 (8080)
- **网关管理**: 服务注册、健康检查、路由信息
- **用户管理**: 代理到用户服务的所有用户操作
- **产品管理**: 代理到产品服务的所有商品操作
- **购物车管理**: 代理到购物车服务的购物车操作
- **订单管理**: 代理到订单服务的订单操作

### 👥 用户服务 (8085)
```
GET    /api/v1/users          # 获取用户列表
POST   /api/v1/users          # 创建新用户
GET    /api/v1/users/{id}     # 获取单个用户
PUT    /api/v1/users/{id}     # 更新用户信息
DELETE /api/v1/users/{id}     # 删除用户
```

### 📦 产品服务 (8082)
```
GET    /api/v1/products       # 获取产品列表
POST   /api/v1/products       # 创建新产品
GET    /api/v1/products/{id}  # 获取单个产品
PUT    /api/v1/products/{id}  # 更新产品信息
DELETE /api/v1/products/{id}  # 删除产品
```

### 🛒 购物车服务 (8083)
```
GET    /api/v1/cart                    # 获取购物车
POST   /api/v1/cart/items             # 添加商品到购物车
PUT    /api/v1/cart/items/{item_id}   # 更新购物车商品
DELETE /api/v1/cart/items/{item_id}   # 删除购物车商品
DELETE /api/v1/cart                   # 清空购物车
GET    /api/v1/cart/summary           # 获取购物车摘要
```

### 📋 订单服务 (8084)
```
GET    /api/v1/orders              # 获取订单列表
POST   /api/v1/orders              # 创建订单
GET    /api/v1/orders/{id}         # 获取单个订单
PUT    /api/v1/orders/{id}/status  # 更新订单状态
PUT    /api/v1/orders/{id}/cancel  # 取消订单
GET    /api/v1/orders/summary      # 获取订单统计
```

## 📝 使用示例

### 示例1：创建用户
```bash
POST http://localhost:8080/api/v1/users
Content-Type: application/json

{
    "name": "张三",
    "email": "zhangsan@example.com",
    "phone": "13800138000"
}
```

### 示例2：添加商品到购物车
```bash
POST http://localhost:8080/api/v1/cart/items?user_id=1
Content-Type: application/json

{
    "product_id": 1,
    "quantity": 2
}
```

### 示例3：创建订单
```bash
POST http://localhost:8080/api/v1/orders
Content-Type: application/json

{
    "user_id": 1,
    "payment_method": "alipay",
    "shipping_address": "北京市朝阳区xxx路xxx号",
    "contact_phone": "13800138000",
    "contact_name": "张三",
    "remark": "请尽快发货"
}
```

## 🔧 开发者工具

### 1. Swagger UI 功能
- **交互式文档**: 直接在浏览器中测试API
- **参数验证**: 自动验证请求参数格式
- **响应示例**: 显示API响应数据结构
- **模型定义**: 查看数据模型结构

### 2. API 测试工具推荐
- **Swagger UI**: 内置的交互式文档
- **Postman**: 导入OpenAPI规范进行测试
- **curl**: 命令行工具
- **HTTPie**: 更友好的命令行HTTP客户端

### 3. OpenAPI 规范导出
访问各服务的 `/swagger/doc.json` 端点获取OpenAPI JSON：
- http://localhost:8080/swagger/doc.json (API网关)
- http://localhost:8085/swagger/doc.json (用户服务)
- http://localhost:8082/swagger/doc.json (产品服务)
- http://localhost:8083/swagger/doc.json (购物车服务)  
- http://localhost:8084/swagger/doc.json (订单服务)

## 🏗️ 微服务架构说明

### API 网关路由规则
API网关负责将请求路由到对应的微服务：

```
/api/v1/users/*     → 用户服务 (8085)
/api/v1/products/*  → 产品服务 (8082)
/api/v1/cart/*      → 购物车服务 (8083)
/api/v1/orders/*    → 订单服务 (8084)
```

### 服务发现和健康检查
- 每个微服务提供 `/health` 端点进行健康检查
- API网关定期检查所有微服务状态
- 访问 http://localhost:8080/health 查看整体服务状态

## 🔍 故障排除

### 常见问题

1. **Swagger 页面无法访问**
   ```bash
   # 检查服务是否正常启动
   docker-compose -f docker-compose.microservices.yml ps
   
   # 检查服务日志
   docker-compose -f docker-compose.microservices.yml logs api-gateway
   ```

2. **API 请求失败**
   - 确认服务已启动
   - 检查请求参数格式
   - 查看服务日志定位问题

3. **跨域问题**
   - API网关已配置CORS支持
   - 前端可直接调用网关接口

### 调试技巧

1. **查看实时日志**
   ```bash
   docker-compose -f docker-compose.microservices.yml logs -f api-gateway
   ```

2. **检查服务注册状态**
   访问: http://localhost:8080/services

3. **查看API路由配置**
   访问: http://localhost:8080/api-routes

## 📚 扩展资源

- [Swagger官方文档](https://swagger.io/docs/)
- [OpenAPI规范](https://spec.openapis.org/oas/v3.0.3)
- [Gin框架文档](https://gin-gonic.com/docs/)
- [Docker Compose文档](https://docs.docker.com/compose/)

---

**🎉 现在开始使用 Go Shop 微服务的 Swagger 文档来探索和测试API吧！** 