# Go Shop 微服务电商平台

基于 Go + Gin 框架的微服务电商平台，支持完全容器化部署。

> **📢 重要提示**：
> - 如果遇到中文乱码：请参考 [编码问题解决方案](./README-编码问题解决方案.md)
> - 如果遇到Docker网络错误：请参考 [Docker网络问题解决指南](./README-Docker网络问题解决.md)
> - 如果遇到IP地址池冲突：运行 `fix-network-ip-conflict.cmd`

## 🌍 多环境部署 (推荐)

支持三个独立环境：**开发环境(DEV)**、**测试环境(UAT)**、**生产环境(PROD)**

### 🚀 统一环境管理器

```bash
# Windows 用户：双击运行环境选择器
environment-launcher.cmd

# 选择对应环境：
# 1. 🔧 启动开发环境 (DEV)
# 2. 🧪 启动测试环境 (UAT)  
# 3. 🚀 启动生产环境 (PROD)
```

### 🌐 环境对比

| 特性 | 开发环境(DEV) | 测试环境(UAT) | 生产环境(PROD) |
|------|---------------|---------------|----------------|
| **API网关** | 8080 | 9080 | 7080,7081 |
| **数据库** | 3307 | 3308 | 3309,3310 |
| **模式** | debug | release | release |
| **架构** | 单机 | 单机 | 主从高可用 |
| **监控** | 基础 | 增强 | 完整 |
| **SSL** | ❌ | ❌ | ✅ |

### ⚡ 直接启动

```bash
# 开发环境
scripts\start-dev.cmd

# 测试环境  
scripts\start-uat.cmd

# 生产环境
scripts\start-prod.cmd
```

## 🚀 快速启动 Docker 微服务 (简化版)

```bash
# Windows 用户：双击运行或命令行执行
docker-microservices-start.cmd

# Linux/macOS 用户
docker-compose -f docker-compose.microservices.yml up -d --build
```

### 📋 简化版服务端口
- **API网关**: 8080 (统一入口)
- **用户服务**: 8085 
- **产品服务**: 8082
- **购物车服务**: 8083
- **订单服务**: 8084
- **MySQL数据库**: 3307

访问：http://localhost:8080

## 功能特性

### 🏗️ 架构特性
- ✅ **微服务架构** - 独立可扩展的服务设计
- ✅ **多环境支持** - DEV/UAT/PROD独立环境部署
- ✅ **容器化部署** - Docker + Docker Compose
- ✅ **MVC分层架构** - 清晰的代码组织结构
- ✅ **RESTful API 设计** - 标准的REST接口

### 💾 数据存储
- ✅ **MySQL 数据库集成** - 完整的数据库支持
- ✅ **GORM ORM 框架** - 强大的对象关系映射
- ✅ **Redis 缓存** - 高性能数据缓存
- ✅ **数据库主从** - 生产环境高可用架构
- ✅ **数据库自动迁移** - 自动创建和更新表结构

### 🌐 API功能
- ✅ **用户管理完整 CRUD 操作** - 增删改查功能
- ✅ **分页查询支持** - 高效的数据分页
- ✅ **软删除功能** - 安全的数据删除
- ✅ **统一响应格式** - 标准化的API响应
- ✅ **请求参数验证** - 严格的数据验证
- ✅ **CORS 跨域支持** - 前端友好的跨域处理

### 🔧 开发体验
- ✅ **依赖注入** - 松耦合的组件设计
- ✅ **中间件支持** - 可插拔的功能组件
- ✅ **日志记录** - 完整的请求日志
- ✅ **错误处理** - 统一的错误处理机制
- ✅ **Swagger文档** - 自动生成的API文档和测试界面
- ✅ **热重载** - 开发环境代码实时更新

### 📊 监控运维
- ✅ **Prometheus监控** - 完整的指标采集
- ✅ **Grafana可视化** - 实时监控面板
- ✅ **ELK日志栈** - 测试和生产环境日志分析
- ✅ **健康检查** - 服务状态实时监控
- ✅ **负载均衡** - 生产环境Nginx负载均衡

### 🛡️ 安全特性
- ✅ **环境隔离** - 不同环境独立配置和数据
- ✅ **SSL支持** - 生产环境HTTPS加密
- ✅ **配置管理** - 环境变量和配置文件管理
- ✅ **消息队列** - 生产环境RabbitMQ支持

## 快速开始

### 前置要求

1. Go 1.21+
2. MySQL 5.7+ 或 8.0+
3. 创建数据库 `gin`

```sql
CREATE DATABASE gin CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 数据库配置

项目使用以下默认配置连接 MySQL：
- Host: localhost
- Port: 3306
- User: root
- Password: root
- Database: gin

如需修改配置，请编辑 `config/database.go` 文件中的 `GetDatabaseConfig()` 函数。

### 方法一：使用 Makefile（推荐）

```bash
# 查看所有可用命令
make help

# 开发环境启动（自动安装依赖、格式化、检查、运行）
make dev

# 或分步执行
make deps    # 安装依赖
make run     # 运行项目
```

### 方法二：手动执行

```bash
# 安装依赖
go mod tidy

# 运行项目（MVC架构）
go run main.go
```

### 项目启动后

服务器启动后会显示：
```
服务器启动在: :8080
[GIN-debug] Listening and serving HTTP on :8080
```

访问 http://localhost:8080 即可看到欢迎页面。

### 📚 Swagger API 文档

项目启动后，可以通过以下地址访问交互式API文档：

**🌟 Swagger UI：** http://localhost:8080/swagger/index.html

通过Swagger文档你可以：
- 📖 查看所有API接口说明
- 🧪 直接在浏览器中测试API
- 📋 查看请求/响应格式
- 🔍 了解参数说明和验证规则

程序启动时会自动：
1. 连接到 MySQL 数据库
2. 创建必要的数据表（自动迁移）
3. 启动 HTTP 服务器

服务器将在 `http://localhost:8080` 启动。

## API 接口

### 基础路由

- `GET /` - 欢迎页面

### API 路由 (前缀: `/api/v1`)

- `GET /api/v1/health` - 健康检查（包含数据库状态）
- `GET /api/v1/users` - 获取用户列表（支持分页）
- `POST /api/v1/users` - 创建新用户
- `GET /api/v1/users/:id` - 根据ID获取用户
- `PUT /api/v1/users/:id` - 更新用户信息
- `DELETE /api/v1/users/:id` - 删除用户（软删除）

### 示例请求

#### 健康检查
```bash
curl http://localhost:8080/api/v1/health

# 或访问Swagger文档进行可视化测试
# http://localhost:8080/swagger/index.html
```

#### 获取用户列表（支持分页）
```bash
# 获取第一页，每页10条
curl http://localhost:8080/api/v1/users

# 获取第二页，每页5条
curl "http://localhost:8080/api/v1/users?page=2&page_size=5"
```

#### 创建用户
```bash
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "张三",
    "email": "zhangsan@example.com",
    "phone": "13888888888"
  }'
```

#### 获取指定用户
```bash
curl http://localhost:8080/api/v1/users/1
```

#### 更新用户
```bash
curl -X PUT http://localhost:8080/api/v1/users/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "李四",
    "phone": "13999999999"
  }'
```

#### 删除用户
```bash
curl -X DELETE http://localhost:8080/api/v1/users/1
```

## 项目结构 (MVC分层架构)

```
gin-project/
├── app/                    # 应用程序主入口
│   └── app.go             # 应用初始化和依赖注入
├── config/                 # 配置相关
│   └── database.go        # 数据库配置
├── controllers/           # 控制器层 (MVC-Controller)
│   ├── user_controller.go # 用户控制器
│   └── health_controller.go # 健康检查控制器
├── middleware/            # 中间件层
│   ├── cors.go           # CORS中间件
│   └── logger.go         # 日志中间件
├── models/               # 模型层 (MVC-Model)
│   └── user.go          # 用户模型
├── repositories/         # 仓储层 (数据访问层)
│   └── user_repository.go # 用户仓储
├── response/            # 响应层 (MVC-View的JSON版本)
│   └── response.go      # 统一响应格式
├── routes/              # 路由层
│   └── routes.go        # 路由定义
├── services/            # 服务层 (业务逻辑层)
│   └── user_service.go  # 用户服务
├── scripts/             # 脚本文件
│   ├── init.sql         # 数据库初始化脚本
│   └── seed_data.go     # 测试数据脚本
├── docs/                # 文档
│   └── architecture.md  # 架构设计文档
├── go.mod               # Go 模块文件
├── go.sum               # 依赖版本锁定
├── main.go              # 程序入口（已重构为MVC）
├── Makefile             # 项目管理命令
└── README.md            # 项目说明
```

## 技术栈

- Go 1.21+
- Gin Web Framework v1.10.1
- GORM v1.25.5 (ORM 框架)
- MySQL Driver v1.5.2
- MySQL 5.7+ / 8.0+

## 数据库表结构

### users 表
```sql
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `avatar` varchar(500) DEFAULT NULL,
  `status` int DEFAULT '1' COMMENT '用户状态 1:正常 0:禁用',
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_users_email` (`email`),
  KEY `idx_users_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## 开发建议

1. ✅ MySQL 数据库集成 - 已完成
2. 实现用户认证和授权 (JWT)
3. ✅ 添加 CORS 中间件 - 已完成
4. 使用配置文件管理环境变量
5. 添加单元测试
6. ✅ 添加日志中间件 - 已完成
7. 实现 API 限流
8. ✅ 添加 Swagger 文档 - 已完成

## 许可证

MIT License 