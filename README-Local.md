# 🏠 Go Shop 本地开发指南

## 📋 概述

本指南将帮助你快速在本地环境中启动和开发 Go Shop 项目。

## 🚀 快速开始

### 方式一：一键启动（推荐）

```bash
# 双击运行
start-local-quick.cmd
```

### 方式二：交互式启动

```bash
# 双击运行
start-local.cmd
```

### 方式三：环境管理器

```bash
# 双击运行
environment-launcher.cmd
# 选择 L. 🏠 本地启动器
```

## 🛠️ 环境要求

### 必需环境

- **Go 1.21+** - [下载地址](https://golang.org/dl/)
- **MySQL 8.0+** - 本地安装或Docker容器
- **Git** - 版本控制

### 可选环境

- **Docker Desktop** - 用于容器化数据库
- **Air** - 热重载工具 (`go install github.com/cosmtrek/air@latest`)
- **Redis** - 缓存服务（可选）

## 📦 安装步骤

### 1. 安装Go环境

```bash
# 下载并安装Go 1.21+
# 设置GOPATH和GOROOT环境变量
# 验证安装
go version
```

### 2. 安装MySQL

#### 方式一：本地安装
```bash
# Windows: 下载MySQL Installer
# macOS: brew install mysql
# Linux: sudo apt install mysql-server
```

#### 方式二：Docker安装
```bash
# 启动MySQL容器
docker run -d --name mysql-local -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=gin_dev \
  mysql:8.0
```

### 3. 安装Air（可选）

```bash
# 安装热重载工具
go install github.com/cosmtrek/air@latest
```

## 🔧 配置说明

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

项目使用 `config/local.env` 作为本地开发配置文件：

```bash
# 加载环境变量
source config/local.env
```

## 🚀 启动模式

### 1. 开发模式

```bash
# 设置环境变量
set GIN_MODE=debug
set LOG_LEVEL=debug

# 启动应用
go run main.go
```

### 2. 生产模式

```bash
# 设置环境变量
set GIN_MODE=release
set LOG_LEVEL=warn

# 启动应用
go run main.go
```

### 3. 热重载模式

```bash
# 使用Air工具
air
```

### 4. 测试模式

```bash
# 运行测试
go test ./... -v -cover
```

## 📊 数据库配置

### MySQL连接配置

```sql
-- 创建数据库
CREATE DATABASE gin_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建用户（可选）
CREATE USER 'gin_dev_user'@'localhost' IDENTIFIED BY 'gin_dev_pass';
GRANT ALL PRIVILEGES ON gin_dev.* TO 'gin_dev_user'@'localhost';
FLUSH PRIVILEGES;
```

### 数据库迁移

项目启动时会自动执行数据库迁移：

```go
// 自动迁移数据库表
err := config.DB.AutoMigrate(&models.User{}, &models.Product{})
```

## 🔍 调试和测试

### API测试

```bash
# 健康检查
curl http://localhost:8080/health

# 用户API
curl http://localhost:8080/api/users
```

### Swagger文档

访问 Swagger UI 文档：
- URL: http://localhost:8080/swagger/index.html
- 支持API测试和文档查看

### 日志查看

```bash
# 查看应用日志
tail -f logs/app.log

# 查看Docker容器日志
docker logs mysql-local
```

## 🛠️ 开发工具

### 代码格式化

```bash
# 格式化代码
go fmt ./...

# 运行代码检查
go vet ./...
```

### 依赖管理

```bash
# 下载依赖
go mod tidy

# 查看依赖
go mod graph

# 清理缓存
go clean -cache
```

### 构建应用

```bash
# 构建可执行文件
go build -o app.exe .

# 交叉编译（Linux）
GOOS=linux GOARCH=amd64 go build -o app .

# 交叉编译（macOS）
GOOS=darwin GOARCH=amd64 go build -o app .
```

## 🔧 故障排除

### 常见问题

#### 1. Go环境问题

```bash
# 检查Go版本
go version

# 检查GOPATH
echo $GOPATH

# 检查GOROOT
echo $GOROOT
```

#### 2. 数据库连接问题

```bash
# 检查MySQL服务
netstat -ano | findstr ":3306"

# 测试数据库连接
mysql -h localhost -P 3306 -u root -proot -e "SELECT 1;"
```

#### 3. 端口占用问题

```bash
# 检查端口占用
netstat -ano | findstr ":8080"

# 杀死占用进程
taskkill /PID <进程ID> /F
```

#### 4. Docker问题

```bash
# 检查Docker状态
docker version

# 重启Docker服务
# Windows: 重启Docker Desktop
# Linux: sudo systemctl restart docker
```

### 日志分析

```bash
# 查看应用日志
tail -f logs/app.log

# 查看错误日志
grep "ERROR" logs/app.log

# 查看性能日志
grep "SLOW" logs/app.log
```

## 📚 相关文档

- [Go官方文档](https://golang.org/doc/)
- [Gin框架文档](https://gin-gonic.com/docs/)
- [GORM文档](https://gorm.io/docs/)
- [Swagger文档](https://swagger.io/docs/)

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📞 技术支持

如果遇到问题，请：

1. 查看本文档的故障排除部分
2. 检查项目Issues
3. 提交新的Issue并描述详细问题

---

**Happy Coding! 🎉** 