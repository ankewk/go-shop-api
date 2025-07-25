@echo off
echo ====================================
echo   启动 Gin 微服务电商平台
echo ====================================

echo.
echo 正在检查 Docker 状态...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] Docker 未安装或未启动
    echo 请确保 Docker Desktop 已安装并运行
    pause
    exit /b 1
)

echo 正在检查 docker-compose...
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] docker-compose 未安装
    pause
    exit /b 1
)

echo.
echo 正在启动微服务架构...
echo 包含服务：
echo   - MySQL 数据库 (3306)
echo   - 用户服务 (8081)
echo   - 产品服务 (8082)
echo   - 购物车服务 (8083)
echo   - 订单服务 (8084)
echo   - API网关 (8080)

docker-compose -f docker-compose.microservices.yml up -d

echo.
echo 等待服务启动...
timeout /t 30

echo.
echo 检查服务状态...
docker-compose -f docker-compose.microservices.yml ps

echo.
echo ====================================
echo   微服务电商平台启动完成！
echo ====================================
echo.
echo 🌐 商城地址: http://localhost:8080/shop
echo 📖 API文档: http://localhost:8080/api-routes
echo 🔧 网关管理: http://localhost:8080/gateway
echo 💾 数据库: localhost:3306 (gin_user/gin_password)
echo.
echo 📋 微服务端点:
echo   - 用户服务: http://localhost:8081/health
echo   - 产品服务: http://localhost:8082/health
echo   - 购物车服务: http://localhost:8083/health
echo   - 订单服务: http://localhost:8084/health
echo   - API网关: http://localhost:8080/health
echo.
echo 📝 管理命令:
echo   查看日志: docker-compose -f docker-compose.microservices.yml logs -f
echo   停止服务: docker-compose -f docker-compose.microservices.yml down
echo   重建服务: docker-compose -f docker-compose.microservices.yml build --no-cache
echo.
pause 