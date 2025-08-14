# 🛒 Go Shop 微服务电商平台

基于 Go + Gin 框架的现代化微服务电商平台，支持完全容器化部署和本地开发。

## 🌟 核心特性

### 🏗️ 架构特性
- **微服务架构** - 独立可扩展的服务设计
- **多环境支持** - DEV/UAT/PROD独立环境部署
- **容器化部署** - Docker + Docker Compose
- **API网关** - 统一入口，路由分发，负载均衡
- **服务发现** - 自动服务注册和发现

### 💾 数据存储
- **MySQL数据库** - 完整的关系型数据支持
- **GORM ORM框架** - 强大的对象关系映射
- **数据库主从** - 生产环境高可用架构
- **自动迁移** - 自动创建和更新表结构

### 🌐 API功能
- **用户管理** - 完整的用户CRUD操作
- **商品管理** - 商品信息管理和库存控制
- **购物车** - 添加、修改、删除购物车商品
- **订单管理** - 订单创建、状态更新、取消
- **分页查询** - 高效的数据分页
- **统一响应格式** - 标准化的API响应

### 🔧 开发体验
- **Swagger文档** - 自动生成API文档和测试界面
- **热重载** - 开发环境代码实时更新
- **健康检查** - 服务状态实时监控
- **日志记录** - 完整的请求日志
- **CORS支持** - 前端友好的跨域处理

### 📊 监控运维
- **Prometheus监控** - 完整的指标采集
- **Grafana可视化** - 实时监控面板
- **容器监控** - Docker容器资源监控
- **日志聚合** - 集中式日志管理

## 🚀 快速开始

### 前置要求

- **Go 1.21+** - [下载地址](https://golang.org/dl/)
- **Docker Desktop** - [下载地址](https://www.docker.com/products/docker-desktop)
- **MySQL 8.0+** - 本地安装或Docker容器

### 方法一：Docker一键部署（推荐）

```bash
# 克隆项目
git clone https://github.com/your-repo/go-shop-api.git
cd go-shop-api

# 启动所有微服务
docker-compose -f docker-compose.microservices.yml up -d --build

# 查看服务状态
docker-compose -f docker-compose.microservices.yml ps
```

### 方法二：本地开发

```bash
# 安装依赖
go mod tidy

# 创建数据库
mysql -u root -p -e "CREATE DATABASE gin_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 启动应用
go run main.go
```

### 方法三：Makefile（跨平台）

```bash
# 查看所有可用命令
make help

# 开发环境启动
make dev

# 生产环境启动
make prod

# 测试环境启动
make test
```

## 🌐 访问地址

### 主要入口
- **商城首页**: http://localhost:8080
- **API网关**: http://localhost:8080/gateway
- **Swagger文档**: http://localhost:8080/swagger/index.html
- **健康检查**: http://localhost:8080/health

### 微服务端点
| 服务名称 | 端口 | Swagger文档 | 健康检查 |
|---------|------|-------------|----------|
| **API网关** | 8080 | [Swagger](http://localhost:8080/swagger/index.html) | [Health](http://localhost:8080/health) |
| 用户服务 | 8085 | [Swagger](http://localhost:8085/swagger/index.html) | [Health](http://localhost:8085/health) |
| 产品服务 | 8082 | [Swagger](http://localhost:8082/swagger/index.html) | [Health](http://localhost:8082/health) |
| 购物车服务 | 8083 | [Swagger](http://localhost:8083/swagger/index.html) | [Health](http://localhost:8083/health) |
| 订单服务 | 8084 | [Swagger](http://localhost:8084/swagger/index.html) | [Health](http://localhost:8084/health) |

## 📋 API接口

### 基础路由
- `GET /` - 欢迎页面
- `GET /health` - 健康检查
- `GET /swagger/index.html` - API文档

### 用户管理 (`/api/v1/users`)
```bash
# 获取用户列表（支持分页）
curl http://localhost:8080/api/v1/users

# 创建用户
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name":"张三","email":"test@example.com","phone":"13800138000"}'

# 获取指定用户
curl http://localhost:8080/api/v1/users/1

# 更新用户
curl -X PUT http://localhost:8080/api/v1/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"李四","phone":"13999999999"}'

# 删除用户
curl -X DELETE http://localhost:8080/api/v1/users/1
```

### 产品管理 (`/api/v1/products`)
```bash
# 获取产品列表
curl http://localhost:8080/api/v1/products

# 创建产品
curl -X POST http://localhost:8080/api/v1/products \
  -H "Content-Type: application/json" \
  -d '{"name":"iPhone 15","price":5999,"stock":100}'
```

### 购物车管理 (`/api/v1/cart`)
```bash
# 获取购物车
curl http://localhost:8080/api/v1/cart?user_id=1

# 添加商品到购物车
curl -X POST http://localhost:8080/api/v1/cart/items?user_id=1 \
  -H "Content-Type: application/json" \
  -d '{"product_id":1,"quantity":2}'
```

### 订单管理 (`/api/v1/orders`)
```bash
# 创建订单
curl -X POST http://localhost:8080/api/v1/orders \
  -H "Content-Type: application/json" \
  -d '{"user_id":1,"items":[{"product_id":1,"quantity":1,"price":5999}]}'
```

## 🛠️ 环境配置

### 环境变量

项目支持以下环境变量配置：

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `DB_HOST` | localhost | 数据库地址 |
| `DB_PORT` | 3306 | 数据库端口 |
| `DB_USER` | root | 数据库用户 |
| `DB_PASSWORD` | root | 数据库密码 |
| `DB_NAME` | gin_dev | 数据库名称 |
| `PORT` | 8080 | 应用端口 |
| `GIN_MODE` | debug | Gin运行模式 |
| `LOG_LEVEL` | debug | 日志级别 |

### 配置文件

项目使用以下配置文件：
- `config/local.env` - 本地开发配置
- `config/dev.env` - 开发环境配置
- `config/uat.env` - 测试环境配置
- `config/prod.env` - 生产环境配置

## 🏗️ 项目结构

```
go-shop-api/
├── app/                    # 应用程序主入口
├── config/                 # 配置相关
├── controllers/           # 控制器层 (MVC-Controller)
├── docker/                # Docker配置
│   ├── docker-compose.*.yml  # 多环境Docker配置
│   ├── mysql/             # MySQL配置
│   ├── nginx/             # Nginx配置
│   └── prometheus/        # 监控配置
├── docs/                  # 项目文档
├── middleware/            # 中间件层
├── models/               # 模型层 (MVC-Model)
├── repositories/         # 仓储层 (数据访问层)
├── response/              # 响应层
├── routes/                # 路由层
├── scripts/               # 脚本文件
├── services/              # 服务层 (业务逻辑层)
│   ├── api-gateway/       # API网关服务
│   ├── user-service/      # 用户服务
│   ├── product-service/   # 产品服务
│   ├── cart-service/      # 购物车服务
│   └── order-service/     # 订单服务
├── shared/                # 共享模块
├── Makefile              # 项目管理命令
├── main.go               # 程序入口
└── README.md             # 项目说明
```

## 🔍 监控和调试

### Docker服务管理

```bash
# 查看服务状态
docker-compose -f docker-compose.microservices.yml ps

# 查看服务日志
docker-compose -f docker-compose.microservices.yml logs -f [服务名]

# 重启服务
docker-compose -f docker-compose.microservices.yml restart [服务名]

# 停止服务
docker-compose -f docker-compose.microservices.yml down
```

### 本地调试

```bash
# 查看应用日志
tail -f logs/app.log

# 数据库连接测试
mysql -h localhost -P 3306 -u root -p -e "SELECT 1;"

# 端口检查
lsof -i :8080
```

### 性能监控

```bash
# 查看容器资源使用
docker stats

# 查看Prometheus指标
http://localhost:9090

# 查看Grafana面板
http://localhost:3000
```

## 🚨 故障排除

### 常见问题

#### 1. 端口被占用
```bash
# 查看端口占用
lsof -i :8080

# 杀死占用进程
kill -9 [PID]
```

#### 2. 数据库连接失败
```bash
# 检查MySQL服务
mysqladmin ping -h localhost

# 检查数据库是否存在
mysql -u root -p -e "SHOW DATABASES;"
```

#### 3. Docker容器启动失败
```bash
# 查看详细错误日志
docker-compose -f docker-compose.microservices.yml logs [服务名]

# 清理未使用的镜像
docker system prune -a
```

#### 4. 权限问题
```bash
# 给脚本添加执行权限
chmod +x scripts/*.sh

# 修复Docker权限
sudo chown -R $USER:$USER .
```

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📚 技术栈

- **后端**: Go 1.21+, Gin Web Framework
- **数据库**: MySQL 8.0+, GORM ORM
- **容器化**: Docker, Docker Compose
- **监控**: Prometheus, Grafana
- **文档**: Swagger/OpenAPI 3.0
- **构建**: Makefile

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 📞 技术支持

如果遇到问题，请：

1. 查看本文档的故障排除部分
2. 检查项目 [Issues](https://github.com/your-repo/go-shop-api/issues)
3. 提交新的Issue并描述详细问题

---

**🎉 恭喜！你的 Go Shop 微服务平台已经成功部署！**

访问 [http://localhost:8080](http://localhost:8080) 开始探索吧！