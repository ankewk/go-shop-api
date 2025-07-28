# Go Shop 微服务 Docker 部署指南

基于 Go + Gin 的微服务电商平台，完全容器化部署方案。

## 🏗️ 系统架构

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   前端用户      │───▶│   API 网关      │───▶│   微服务集群    │
│  (浏览器/APP)   │    │   (8080)        │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │                        │
                              ▼                        ▼
                    ┌─────────────────┐    ┌─────────────────┐
                    │   负载均衡      │    │   数据库集群    │
                    │   服务发现      │    │   MySQL (3306)  │
                    └─────────────────┘    └─────────────────┘
```

## 📦 微服务组件

| 服务名称 | 端口 | 功能描述 | 容器名称 |
|---------|------|---------|---------|
| API 网关 | 8080 | 统一入口，路由分发，负载均衡 | gin-api-gateway |
| 用户服务 | 8081 | 用户管理，身份认证 | gin-user-service |
| 产品服务 | 8082 | 商品管理，库存控制 | gin-product-service |
| 购物车服务 | 8083 | 购物车管理，商品收藏 | gin-cart-service |
| 订单服务 | 8084 | 订单处理，支付管理 | gin-order-service |
| MySQL 数据库 | 3306 | 数据持久化存储 | gin-mysql |

## 🚀 快速启动

### 前置条件

1. **安装 Docker Desktop**
   ```bash
   # Windows: 下载 Docker Desktop for Windows
   # https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe
   
   # macOS: 下载 Docker Desktop for Mac
   # https://desktop.docker.com/mac/main/amd64/Docker.dmg
   
   # Linux: 安装 Docker 和 docker-compose
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   sudo apt-get install docker-compose
   ```

2. **验证安装**
   ```bash
   docker --version
   docker-compose --version
   ```

### 一键启动

**Windows 用户：**
```cmd
# 双击运行
docker-microservices-start.cmd

# 或命令行运行
.\docker-microservices-start.cmd
```

**Linux/macOS 用户：**
```bash
# 启动所有微服务
docker-compose -f docker-compose.microservices.yml up -d --build

# 查看启动状态
docker-compose -f docker-compose.microservices.yml ps
```

## 🔧 服务管理

### 查看服务状态
```bash
docker-compose -f docker-compose.microservices.yml ps
```

### 查看服务日志
```bash
# 查看所有服务日志
docker-compose -f docker-compose.microservices.yml logs -f

# 查看特定服务日志
docker-compose -f docker-compose.microservices.yml logs -f api-gateway
docker-compose -f docker-compose.microservices.yml logs -f user-service
```

### 重启服务
```bash
# 重启所有服务
docker-compose -f docker-compose.microservices.yml restart

# 重启特定服务
docker-compose -f docker-compose.microservices.yml restart api-gateway
```

### 停止服务
```bash
# 停止所有服务
docker-compose -f docker-compose.microservices.yml down

# 停止并删除数据卷（危险操作）
docker-compose -f docker-compose.microservices.yml down -v
```

### 重建服务
```bash
# 重新构建并启动
docker-compose -f docker-compose.microservices.yml up -d --build --force-recreate
```

## 🌐 访问地址

### 主要入口
- **商城首页**: http://localhost:8080
- **API 网关**: http://localhost:8080/gateway
- **健康检查**: http://localhost:8080/health
- **API 路由**: http://localhost:8080/api-routes
- **服务列表**: http://localhost:8080/services

### 微服务端点
- **用户服务**: http://localhost:8081/health
- **产品服务**: http://localhost:8082/health
- **购物车服务**: http://localhost:8083/health
- **订单服务**: http://localhost:8084/health

### API 接口示例
```bash
# 获取用户列表
curl http://localhost:8080/api/v1/users

# 获取产品列表
curl http://localhost:8080/api/v1/products

# 创建新用户
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name":"测试用户","email":"test@example.com","phone":"13800138000"}'

# 添加商品到购物车
curl -X POST "http://localhost:8080/api/v1/cart/items?user_id=1" \
  -H "Content-Type: application/json" \
  -d '{"product_id":1,"quantity":2}'
```

## 💾 数据库访问

### 连接信息
- **主机**: localhost
- **端口**: 3306
- **数据库**: gin
- **用户名**: gin_user
- **密码**: gin_password

### 使用客户端连接
```bash
# 使用 MySQL 客户端
mysql -h localhost -P 3306 -u gin_user -p gin

# 使用 Docker 容器连接
docker exec -it gin-mysql mysql -u gin_user -p gin
```

## 🔍 监控和调试

### 容器资源监控
```bash
# 查看容器资源使用情况
docker stats

# 查看特定容器状态
docker inspect gin-api-gateway
```

### 进入容器调试
```bash
# 进入 API 网关容器
docker exec -it gin-api-gateway sh

# 进入数据库容器
docker exec -it gin-mysql bash
```

### 网络调试
```bash
# 查看 Docker 网络
docker network ls

# 查看微服务网络详情
docker network inspect go-shop-api_microservices-network
```

## 🛠️ 开发和部署

### 开发模式
```bash
# 挂载源码进行开发（修改 docker-compose.yml）
docker-compose -f docker-compose.microservices.yml -f docker-compose.dev.yml up -d
```

### 生产部署
```bash
# 设置生产环境变量
export GIN_MODE=release

# 使用生产配置启动
docker-compose -f docker-compose.microservices.yml up -d
```

### 扩展服务
```bash
# 扩展用户服务到 3 个实例
docker-compose -f docker-compose.microservices.yml up -d --scale user-service=3
```

## 🔐 安全配置

### 环境变量配置
创建 `.env` 文件：
```env
# 数据库配置
DB_ROOT_PASSWORD=your_root_password
DB_PASSWORD=your_password
DB_USER=your_user

# 应用配置
GIN_MODE=release
JWT_SECRET=your_jwt_secret
```

### 网络安全
- 所有服务运行在独立的 Docker 网络中
- 数据库不对外暴露，仅微服务内部访问
- API 网关作为唯一外部入口

## 📊 性能优化

### 资源限制
```yaml
services:
  api-gateway:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

### 缓存配置
- Redis 缓存层（可选）
- 数据库连接池优化
- 静态资源 CDN 加速

## 🚨 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   # 查看端口占用
   netstat -tlnp | grep :8080
   
   # 杀掉占用进程
   kill -9 <PID>
   ```

2. **容器启动失败**
   ```bash
   # 查看详细错误日志
   docker-compose -f docker-compose.microservices.yml logs api-gateway
   ```

3. **数据库连接失败**
   ```bash
   # 检查数据库容器状态
   docker exec gin-mysql mysqladmin ping -h localhost
   ```

4. **内存不足**
   ```bash
   # 清理未使用的镜像和容器
   docker system prune -a
   ```

### 日志收集
```bash
# 导出所有服务日志
docker-compose -f docker-compose.microservices.yml logs > microservices.log
```

## 📝 维护说明

### 备份数据
```bash
# 备份数据库
docker exec gin-mysql mysqldump -u gin_user -p gin > backup.sql

# 备份数据卷
docker run --rm -v go-shop-api_mysql_data:/data -v $(pwd):/backup alpine tar czf /backup/mysql_backup.tar.gz /data
```

### 更新服务
```bash
# 拉取最新代码
git pull origin main

# 重新构建并部署
docker-compose -f docker-compose.microservices.yml up -d --build
```

---

**🎉 恭喜！你的 Go Shop 微服务平台已经在 Docker 中成功运行！**

如有问题，请查看日志或联系技术支持。 