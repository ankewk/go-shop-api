@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   🚀 Go Shop 微服务启动器 (简化版)
echo =====================================
echo.

:: 检查Go环境
echo 🔍 检查Go环境...
go version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Go环境未安装或未配置
    pause
    exit /b 1
)
echo ✅ Go环境检查通过

:: 检查MySQL
echo 🗄️ 检查MySQL数据库...
netstat -ano | findstr ":3306" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ MySQL未运行，请先启动MySQL
    echo 可以使用: docker run -d --name mysql-local -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=gin_dev mysql:8.0
    pause
    exit /b 1
)
echo ✅ MySQL运行正常

:: 设置环境变量
set DB_HOST=localhost
set DB_PORT=3306
set DB_USER=root
set DB_PASSWORD=root
set DB_NAME=gin_dev
set GIN_MODE=debug

echo.
echo 🔧 环境配置：
echo   - 数据库: %DB_HOST%:%DB_PORT%/%DB_NAME%
echo   - 用户: %DB_USER%
echo   - 模式: %GIN_MODE%
echo.

:: 下载依赖
echo 📦 下载依赖...
go mod tidy
echo ✅ 依赖下载完成
echo.

:: 启动用户服务
echo 👥 启动用户服务 (8085)...
cd services\user-service
start "用户服务" cmd /k "set PORT=8085 && set DB_HOST=%DB_HOST% && set DB_PORT=%DB_PORT% && set DB_USER=%DB_USER% && set DB_PASSWORD=%DB_PASSWORD% && set DB_NAME=%DB_NAME% && set GIN_MODE=%GIN_MODE% && echo 用户服务启动中... && go run main.go"
cd ..\..

:: 等待用户服务启动
timeout /t 5

:: 启动产品服务
echo 📦 启动产品服务 (8082)...
cd services\product-service
start "产品服务" cmd /k "set PORT=8082 && set DB_HOST=%DB_HOST% && set DB_PORT=%DB_PORT% && set DB_USER=%DB_USER% && set DB_PASSWORD=%DB_PASSWORD% && set DB_NAME=%DB_NAME% && set GIN_MODE=%GIN_MODE% && echo 产品服务启动中... && go run main.go"
cd ..\..

:: 等待产品服务启动
timeout /t 5

:: 启动购物车服务
echo 🛒 启动购物车服务 (8083)...
cd services\cart-service
start "购物车服务" cmd /k "set PORT=8083 && set DB_HOST=%DB_HOST% && set DB_PORT=%DB_PORT% && set DB_USER=%DB_USER% && set DB_PASSWORD=%DB_PASSWORD% && set DB_NAME=%DB_NAME% && set GIN_MODE=%GIN_MODE% && echo 购物车服务启动中... && go run main.go"
cd ..\..

:: 等待购物车服务启动
timeout /t 5

:: 启动订单服务
echo 📋 启动订单服务 (8084)...
cd services\order-service
start "订单服务" cmd /k "set PORT=8084 && set DB_HOST=%DB_HOST% && set DB_PORT=%DB_PORT% && set DB_USER=%DB_USER% && set DB_PASSWORD=%DB_PASSWORD% && set DB_NAME=%DB_NAME% && set GIN_MODE=%GIN_MODE% && echo 订单服务启动中... && go run main.go"
cd ..\..

:: 等待订单服务启动
timeout /t 5

:: 启动API网关
echo 🌐 启动API网关 (8080)...
cd services\api-gateway
start "API网关" cmd /k "set PORT=8080 && set DB_HOST=%DB_HOST% && set DB_PORT=%DB_PORT% && set DB_USER=%DB_USER% && set DB_PASSWORD=%DB_PASSWORD% && set DB_NAME=%DB_NAME% && set GIN_MODE=%GIN_MODE% && echo API网关启动中... && go run main.go"
cd ..\..

echo.
echo ⏳ 等待所有服务启动...
timeout /t 10

echo.
echo =====================================
echo   🎉 微服务启动完成！
echo =====================================
echo.
echo 📊 服务状态：
echo   ├─ 👥 用户服务: http://localhost:8085/health
echo   ├─ 📦 产品服务: http://localhost:8082/health
echo   ├─ 🛒 购物车服务: http://localhost:8083/health
echo   ├─ 📋 订单服务: http://localhost:8084/health
echo   └─ 🌐 API网关: http://localhost:8080/health
echo.
echo 📖 Swagger文档：
echo   ├─ 👥 用户服务: http://localhost:8085/swagger/index.html
echo   ├─ 📦 产品服务: http://localhost:8082/swagger/index.html
echo   ├─ 🛒 购物车服务: http://localhost:8083/swagger/index.html
echo   ├─ 📋 订单服务: http://localhost:8084/swagger/index.html
echo   └─ 🌐 API网关: http://localhost:8080/swagger/index.html
echo.
echo 🏪 商城入口：
echo   ├─ 🌐 商城首页: http://localhost:8080/shop
echo   ├─ 🔧 网关管理: http://localhost:8080/gateway
echo   └─ 📖 API路由: http://localhost:8080/api-routes
echo.

pause 