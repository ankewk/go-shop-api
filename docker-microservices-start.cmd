@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   启动 Go Shop Docker 微服务
echo =====================================

echo.
echo 正在检查 Docker 环境...

:: 检查 Docker 是否安装
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] Docker 未安装或未启动
    echo 请确保 Docker Desktop 已安装并运行
    pause
    exit /b 1
)

:: 检查 docker-compose 是否可用
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] docker-compose 未安装
    echo 请确保 Docker Desktop 包含 docker-compose
    pause
    exit /b 1
)

echo ✅ Docker 环境检查通过

echo.
echo 正在构建并启动微服务容器...
echo.
echo 📦 包含的服务：
echo   - MySQL 数据库 (3306)
echo   - 用户服务 (8081)
echo   - 产品服务 (8082)
echo   - 购物车服务 (8083)
echo   - 订单服务 (8084)
echo   - API网关 (8080)
echo.

:: 停止可能存在的旧容器
echo 🧹 清理旧容器...
docker-compose -f docker-compose.microservices.yml down

:: 构建并启动所有服务
echo 🚀 启动微服务架构...
docker-compose -f docker-compose.microservices.yml up -d --build

if %errorlevel% neq 0 (
    echo [错误] 启动失败
    pause
    exit /b 1
)

echo.
echo ⏳ 等待服务启动完成...
timeout /t 60

echo.
echo 📊 检查服务状态...
docker-compose -f docker-compose.microservices.yml ps

echo.
echo =====================================
echo   🎉 微服务启动完成！
echo =====================================
echo.
echo 🌐 访问地址：
echo   主页:        http://localhost:8080
echo   商城:        http://localhost:8080/shop
echo   API网关:     http://localhost:8080/gateway
echo   健康检查:    http://localhost:8080/health
echo   API路由:     http://localhost:8080/api-routes
echo   服务列表:    http://localhost:8080/services
echo.
echo 🔧 数据库连接：
echo   地址: localhost:3306
echo   数据库: gin
echo   用户: gin_user
echo   密码: gin_password
echo.
echo 📝 微服务端点：
echo   用户服务:    http://localhost:8081/health
echo   产品服务:    http://localhost:8082/health
echo   购物车服务:  http://localhost:8083/health
echo   订单服务:    http://localhost:8084/health
echo.
echo 🛠️ 管理命令：
echo   查看日志:    docker-compose -f docker-compose.microservices.yml logs -f
echo   停止服务:    docker-compose -f docker-compose.microservices.yml down
echo   重启服务:    docker-compose -f docker-compose.microservices.yml restart
echo   重建服务:    docker-compose -f docker-compose.microservices.yml up -d --build
echo   查看状态:    docker-compose -f docker-compose.microservices.yml ps
echo.
echo 💡 提示：
echo   - 所有服务已容器化，独立运行
echo   - 数据库数据持久化存储
echo   - 支持服务独立扩展和重启
echo   - 通过API网关统一访问所有服务
echo.
pause 