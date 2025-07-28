@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   🚀 Go Shop 开发环境 - 简化启动
echo =====================================

:: 设置环境变量
set ENVIRONMENT=dev
set ENV_FILE=config\dev.env

echo 🔧 当前环境: 开发环境 (简化版)
echo 📋 环境配置: %ENV_FILE%
echo.

:: 检查Docker
echo 🔍 检查Docker状态...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] Docker未运行，请启动Docker Desktop
    pause
    exit /b 1
)
echo ✅ Docker运行正常
echo.

:: 清理旧容器
echo 🧹 清理可能冲突的容器...
docker stop gin-mysql-dev gin-redis-dev gin-api-gateway-dev >nul 2>&1
docker rm gin-mysql-dev gin-redis-dev gin-api-gateway-dev >nul 2>&1
echo ✅ 清理完成
echo.

:: 创建网络
echo 🌐 创建Docker网络...
docker network create go-shop-dev-network >nul 2>&1
echo ✅ 网络准备完成
echo.

:: 分步启动服务
echo 🗄️ 第一步：启动MySQL数据库...
docker run -d --name gin-mysql-dev --network go-shop-dev-network -p 3307:3306 -e MYSQL_ROOT_PASSWORD=dev_root_123 -e MYSQL_DATABASE=gin_dev -e MYSQL_USER=gin_dev_user -e MYSQL_PASSWORD=gin_dev_pass mysql:8.0 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci

if %errorlevel% neq 0 (
    echo [错误] MySQL启动失败
    pause
    exit /b 1
)
echo ✅ MySQL启动成功
echo.

echo ⏳ 等待MySQL初始化...
timeout /t 30

echo 🔄 第二步：启动Redis缓存...
docker run -d --name gin-redis-dev --network go-shop-dev-network -p 6379:6379 redis:7-alpine redis-server --requirepass dev_redis_123

if %errorlevel% neq 0 (
    echo [错误] Redis启动失败
    pause
    exit /b 1
)
echo ✅ Redis启动成功
echo.

echo 🌐 第三步：启动API网关...
:: 使用简化的网关配置
docker run -d --name gin-api-gateway-dev --network go-shop-dev-network -p 8080:8080 -e PORT=8080 -e GIN_MODE=debug nginx:alpine

if %errorlevel% neq 0 (
    echo [错误] API网关启动失败
    pause
    exit /b 1
)
echo ✅ API网关启动成功
echo.

echo 📊 检查容器状态...
docker ps --filter name=gin-

echo.
echo =====================================
echo   🎉 开发环境启动完成！
echo =====================================
echo.
echo 🌐 服务访问地址：
echo   ┌─ 📊 容器状态检查: docker ps
echo   ├─ 🗄️ MySQL数据库: localhost:3307
echo   ├─ 🔄 Redis缓存: localhost:6379
echo   └─ 🌐 API网关: http://localhost:8080
echo.
echo 🔧 数据库连接信息：
echo   ├─ 地址: localhost:3307
echo   ├─ 数据库: gin_dev
echo   ├─ 用户: gin_dev_user
echo   └─ 密码: gin_dev_pass
echo.
echo 🛠️ 管理命令：
echo   ├─ 查看日志: docker logs gin-mysql-dev
echo   ├─ 停止服务: docker stop gin-mysql-dev gin-redis-dev gin-api-gateway-dev
echo   └─ 删除容器: docker rm gin-mysql-dev gin-redis-dev gin-api-gateway-dev
echo.
echo 💡 下一步：
echo   现在可以手动启动Go微服务，它们会连接到这些Docker服务
echo.

pause 