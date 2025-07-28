@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   🚀 Go Shop 开发环境 (无网络模式)
echo =====================================
echo.
echo 💡 这是最简化的启动方案，不使用Docker网络
echo    适用于解决网络IP冲突无法解决的情况
echo.

:: 设置环境变量
set ENVIRONMENT=dev
set ENV_FILE=config\dev-backup.env

echo 🔧 当前环境: 开发环境 (无网络模式)
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
docker stop gin-mysql-simple gin-redis-simple >nul 2>&1
docker rm gin-mysql-simple gin-redis-simple >nul 2>&1
echo ✅ 清理完成
echo.

:: 直接启动容器（不使用自定义网络）
echo 🗄️ 第一步：启动MySQL数据库 (端口3309)...
docker run -d --name gin-mysql-simple ^
  -p 3309:3306 ^
  -e MYSQL_ROOT_PASSWORD=dev_root_123 ^
  -e MYSQL_DATABASE=gin_dev ^
  -e MYSQL_USER=gin_dev_user ^
  -e MYSQL_PASSWORD=gin_dev_pass ^
  mysql:8.0 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci

if %errorlevel% neq 0 (
    echo [错误] MySQL启动失败
    pause
    exit /b 1
)
echo ✅ MySQL启动成功 (端口: 3309)
echo.

echo ⏳ 等待MySQL初始化...
timeout /t 30

echo 🔄 第二步：启动Redis缓存 (端口6381)...
docker run -d --name gin-redis-simple ^
  -p 6381:6379 ^
  redis:7-alpine redis-server --requirepass dev_redis_123

if %errorlevel% neq 0 (
    echo [错误] Redis启动失败
    pause
    exit /b 1
)
echo ✅ Redis启动成功 (端口: 6381)
echo.

echo 📊 检查容器状态...
docker ps --filter name=gin-mysql-simple --filter name=gin-redis-simple

echo.
echo =====================================
echo   🎉 简化环境启动完成！
echo =====================================
echo.
echo 🌐 服务信息：
echo   ├─ 🗄️ MySQL数据库: localhost:3309
echo   ├─ 🔄 Redis缓存: localhost:6381  
echo   └─ 📝 注意：未使用Docker网络
echo.
echo 🔧 数据库连接信息：
echo   ├─ 地址: localhost:3309 (特殊端口!)
echo   ├─ 数据库: gin_dev
echo   ├─ 用户: gin_dev_user
echo   ├─ 密码: gin_dev_pass
echo   └─ Redis密码: dev_redis_123
echo.
echo 💡 启动Go微服务：
echo   现在需要手动启动Go微服务，并配置连接到：
echo   - MySQL端口: 3309
echo   - Redis端口: 6381
echo.
echo 🛠️ 管理命令：
echo   ├─ 查看容器: docker ps
echo   ├─ 停止服务: docker stop gin-mysql-simple gin-redis-simple
echo   ├─ 删除容器: docker rm gin-mysql-simple gin-redis-simple
echo   └─ 查看日志: docker logs gin-mysql-simple
echo.
echo 🔥 Go微服务启动命令示例：
echo   set DB_PORT=3309 ^&^& set REDIS_PORT=6381 ^&^& go run main.go
echo.

pause 