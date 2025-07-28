@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   启动 Go 微服务架构
echo =====================================

echo.
echo 正在启动微服务...

echo 1. 启动用户服务 (端口 8081)...
start "User Service" cmd /k "cd /d %~dp0services\user-service && go run main.go"

timeout /t 3

echo 2. 启动产品服务 (端口 8082)...
start "Product Service" cmd /k "cd /d %~dp0services\product-service && go run main.go"

timeout /t 3

echo 3. 启动购物车服务 (端口 8083)...
start "Cart Service" cmd /k "cd /d %~dp0services\cart-service && go run main.go"

timeout /t 3

echo 4. 启动订单服务 (端口 8084)...
start "Order Service" cmd /k "cd /d %~dp0services\order-service && go run main.go"

timeout /t 3

echo 5. 启动API网关 (端口 8080)...
start "API Gateway" cmd /k "cd /d %~dp0services\api-gateway && go run main.go"

echo.
echo =====================================
echo   所有微服务正在启动中...
echo =====================================
echo.
echo 🌐 网关地址: http://localhost:8080
echo 📖 API路由: http://localhost:8080/api-routes
echo 🔧 健康检查: http://localhost:8080/health
echo 👥 用户服务: http://localhost:8081/health
echo 📦 产品服务: http://localhost:8082/health
echo 🛒 购物车服务: http://localhost:8083/health
echo 📋 订单服务: http://localhost:8084/health
echo.
echo 每个服务将在单独的窗口中运行
echo 关闭窗口即可停止对应的服务
echo.
pause 