# Docker 部署指南

本文档介绍如何使用 Docker 和 Docker Compose 部署 Gin MVC 项目。

## 📋 前置要求

- Docker Desktop (Windows/Mac) 或 Docker Engine (Linux)
- Docker Compose

## 🚀 快速开始

### 1. 生产环境部署

使用预配置的脚本一键启动：

```bash
# Windows
docker-start.bat

# Linux/Mac
docker-compose up -d
```

### 2. 开发环境部署

```bash
# Windows
docker-dev.bat

# Linux/Mac
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d
```

## 📁 Docker 文件说明

### 核心文件

- `Dockerfile` - Go 应用的多阶段构建配置
- `docker-compose.yml` - 生产环境服务编排
- `docker-compose.override.yml` - 开发环境覆盖配置
- `.dockerignore` - Docker 构建忽略文件

### 管理脚本

- `docker-start.bat` - 启动生产环境
- `docker-dev.bat` - 启动开发环境
- `docker-stop.bat` - 停止所有服务
- `docker-rebuild.bat` - 重建镜像并启动

## 🔧 服务配置

### 应用服务 (app)

- **端口**: 8080
- **镜像**: 本地构建
- **环境变量**:
  - `DB_HOST=mysql`
  - `DB_PORT=3306`
  - `DB_USER=gin_user`
  - `DB_PASSWORD=gin_password`
  - `DB_NAME=gin`
  - `GIN_MODE=release`

### 数据库服务 (mysql)

- **端口**: 3306 (生产) / 3307 (开发)
- **镜像**: mysql:8.0
- **数据库**: gin / gin_dev
- **用户**: gin_user / gin_dev
- **密码**: gin_password / gin_dev

## 🌐 访问地址

### 生产环境

- 应用主页: http://localhost:8080
- API文档: http://localhost:8080/swagger/index.html
- 健康检查: http://localhost:8080/api/v1/health
- MySQL: localhost:3306

### 开发环境

- 应用主页: http://localhost:8080
- API文档: http://localhost:8080/swagger/index.html
- MySQL: localhost:3307 (避免端口冲突)

## 🛠️ 常用命令

### 启动服务

```bash
# 启动所有服务
docker-compose up -d

# 启动开发环境
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d
```

### 查看状态

```bash
# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f app
docker-compose logs -f mysql
```

### 停止和清理

```bash
# 停止服务
docker-compose down

# 停止服务并删除数据卷
docker-compose down -v

# 重建镜像
docker-compose build --no-cache
```

### 进入容器

```bash
# 进入应用容器
docker exec -it gin-app sh

# 进入数据库容器
docker exec -it gin-mysql mysql -u gin_user -p
```

## 🗄️ 数据初始化

项目包含以下初始化脚本：

1. `scripts/init.sql` - 数据库表结构初始化
2. `scripts/seed_data.sql` - 示例数据插入

这些脚本会在MySQL容器首次启动时自动执行。

### 示例数据

- **用户**: 张三、李四、王五、管理员
- **产品**: iPhone 15、MacBook Pro、iPad Air、AirPods Pro、Apple Watch

## 🔍 健康检查

两个服务都配置了健康检查：

- **MySQL**: 使用 `mysqladmin ping` 检查
- **App**: 访问 `/api/v1/health` 端点检查

## 📊 监控和调试

### 查看资源使用情况

```bash
# 查看容器资源使用
docker stats

# 查看网络
docker network ls
docker network inspect gin_gin-network
```

### 数据库连接测试

```bash
# 从应用容器测试数据库连接
docker exec -it gin-app sh
# 在容器内执行
wget -qO- http://localhost:8080/api/v1/health
```

## 🚨 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   # 检查端口使用情况
   netstat -ano | findstr :8080
   netstat -ano | findstr :3306
   ```

2. **数据库连接失败**
   ```bash
   # 检查数据库服务状态
   docker-compose logs mysql
   
   # 重启数据库服务
   docker-compose restart mysql
   ```

3. **应用启动失败**
   ```bash
   # 查看应用日志
   docker-compose logs app
   
   # 重建应用镜像
   docker-compose build --no-cache app
   ```

4. **清理所有数据重新开始**
   ```bash
   docker-compose down -v
   docker system prune -a
   docker-compose up -d
   ```

## ⚙️ 环境变量配置

你可以通过以下方式自定义配置：

1. 修改 `docker-compose.yml` 中的环境变量
2. 创建 `.env` 文件（参考 `.env.example`）
3. 使用 `docker-compose.override.yml` 覆盖设置

### 示例 .env 文件

```env
# 数据库配置
DB_HOST=mysql
DB_PORT=3306
DB_USER=gin_user
DB_PASSWORD=your_password
DB_NAME=gin

# 应用配置
GIN_MODE=release
PORT=8080
```

## 🔒 安全建议

1. **生产环境**:
   - 修改默认密码
   - 使用强密码
   - 配置防火墙规则
   - 定期更新镜像

2. **网络安全**:
   - 不要暴露数据库端口到公网
   - 使用 HTTPS (需要配置反向代理)
   - 定期备份数据

## 📝 更新和维护

### 更新应用

```bash
# 停止服务
docker-compose down

# 拉取最新代码
git pull

# 重建并启动
docker-compose up -d --build
```

### 数据备份

```bash
# 备份数据库
docker exec gin-mysql mysqldump -u gin_user -p gin > backup.sql

# 恢复数据库
docker exec -i gin-mysql mysql -u gin_user -p gin < backup.sql
```

这就是完整的 Docker 部署指南。如有问题，请查看日志或联系开发团队。 