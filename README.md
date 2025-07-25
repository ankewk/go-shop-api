# Gin 项目

这是一个使用 Gin 框架构建的 Go Web 应用程序。

## 功能特性

- ✅ **MVC分层架构** - 清晰的代码组织结构
- ✅ **RESTful API 设计** - 标准的REST接口
- ✅ **MySQL 数据库集成** - 完整的数据库支持
- ✅ **GORM ORM 框架** - 强大的对象关系映射
- ✅ **依赖注入** - 松耦合的组件设计
- ✅ **用户管理完整 CRUD 操作** - 增删改查功能
- ✅ **数据库自动迁移** - 自动创建和更新表结构
- ✅ **分页查询支持** - 高效的数据分页
- ✅ **软删除功能** - 安全的数据删除
- ✅ **统一响应格式** - 标准化的API响应
- ✅ **请求参数验证** - 严格的数据验证
- ✅ **CORS 跨域支持** - 前端友好的跨域处理
- ✅ **中间件支持** - 可插拔的功能组件
- ✅ **日志记录** - 完整的请求日志
- ✅ **错误处理** - 统一的错误处理机制
- ✅ **Swagger文档** - 自动生成的API文档和测试界面

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