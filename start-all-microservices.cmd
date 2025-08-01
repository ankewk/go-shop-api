@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   🚀 Go Shop 微服务集群启动器
echo =====================================
echo.

echo 📋 启动所有微服务：
echo   ├─ 🗄️  MySQL数据库
echo   ├─ 👥 用户服务 (8085)
echo   ├─ 📦 产品服务 (8082)
echo   ├─ 🛒 购物车服务 (8083)
echo   ├─ 📋 订单服务 (8084)
echo   └─ 🌐 API网关 (8080)
echo.

:: 检查Go环境
echo 🔍 检查Go环境...
go version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Go环境未安装或未配置
    echo 请先安装Go 1.21+
    pause
    exit /b 1
)
echo ✅ Go环境检查通过
echo.

:: 检查并启动MySQL
echo 🗄️ 检查MySQL数据库...
netstat -ano | findstr ":3306" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 检测到MySQL服务运行在3306端口
) else (
    echo 🐳 未检测到MySQL，启动Docker MySQL...
    docker run -d --name mysql-local -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=gin_dev mysql:8.0
    echo ⏳ 等待MySQL初始化...
    timeout /t 30
    echo ✅ MySQL容器启动成功
)

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

:: 下载所有依赖
echo 📦 下载Go依赖...
go mod tidy
if %errorlevel% neq 0 (
    echo ❌ 依赖下载失败
    pause
    exit /b 1
)
echo ✅ 依赖下载完成
echo.

:: 启动用户服务
echo 👥 启动用户服务 (端口:8085)...
if exist "services\user-service\main.go" (
    start "用户服务" cmd /k "cd /d services\user-service && set PORT=8085 && set DB_HOST=%DB_HOST% && set DB_PORT=%DB_PORT% && set DB_USER=%DB_USER% && set DB_PASSWORD=%DB_PASSWORD% && set DB_NAME=%DB_NAME% && set GIN_MODE=%GIN_MODE% && echo 👥 用户服务启动中... && echo   端口: 8085 && echo   数据库: %DB_HOST%:%DB_PORT%/%DB_NAME% && echo   Swagger: http://localhost:8085/swagger/index.html && echo. && go run main.go"
    timeout /t 3
) else (
    echo ❌ 用户服务文件不存在: services\user-service\main.go
)

:: 启动产品服务
echo 📦 启动产品服务 (端口:8082)...
if exist "services\product-service\main.go" (
    start "产品服务" cmd /k "cd /d services\product-service && set PORT=8082 && set DB_HOST=%DB_HOST% && set DB_PORT=%DB_PORT% && set DB_USER=%DB_USER% && set DB_PASSWORD=%DB_PASSWORD% && set DB_NAME=%DB_NAME% && set GIN_MODE=%GIN_MODE% && echo 📦 产品服务启动中... && echo   端口: 8082 && echo   数据库: %DB_HOST%:%DB_PORT%/%DB_NAME% && echo   Swagger: http://localhost:8082/swagger/index.html && echo. && go run main.go"
    timeout /t 3
) else (
    echo ❌ 产品服务文件不存在: services\product-service\main.go
)

:: 启动购物车服务
echo 🛒 启动购物车服务 (端口:8083)...
if exist "services\cart-service\main.go" (
    start "购物车服务" cmd /k "cd /d services\cart-service && set PORT=8083 && set DB_HOST=%DB_HOST% && set DB_PORT=%DB_PORT% && set DB_USER=%DB_USER% && set DB_PASSWORD=%DB_PASSWORD% && set DB_NAME=%DB_NAME% && set GIN_MODE=%GIN_MODE% && echo 🛒 购物车服务启动中... && echo   端口: 8083 && echo   数据库: %DB_HOST%:%DB_PORT%/%DB_NAME% && echo   Swagger: http://localhost:8083/swagger/index.html && echo. && go run main.go"
    timeout /t 3
) else (
    echo ❌ 购物车服务文件不存在: services\cart-service\main.go
)

:: 启动订单服务
echo 📋 启动订单服务 (端口:8084)...
if exist "services\order-service\main.go" (
    start "订单服务" cmd /k "cd /d services\order-service && set PORT=8084 && set DB_HOST=%DB_HOST% && set DB_PORT=%DB_PORT% && set DB_USER=%DB_USER% && set DB_PASSWORD=%DB_PASSWORD% && set DB_NAME=%DB_NAME% && set GIN_MODE=%GIN_MODE% && echo 📋 订单服务启动中... && echo   端口: 8084 && echo   数据库: %DB_HOST%:%DB_PORT%/%DB_NAME% && echo   Swagger: http://localhost:8084/swagger/index.html && echo. && go run main.go"
    timeout /t 3
) else (
    echo ❌ 订单服务文件不存在: services\order-service\main.go
)

:: 启动API网关
echo 🌐 启动API网关 (端口:8080)...
if exist "services\api-gateway\main.go" (
    start "API网关" cmd /k "cd /d services\api-gateway && set PORT=8080 && set DB_HOST=%DB_HOST% && set DB_PORT=%DB_PORT% && set DB_USER=%DB_USER% && set DB_PASSWORD=%DB_PASSWORD% && set DB_NAME=%DB_NAME% && set GIN_MODE=%GIN_MODE% && echo 🌐 API网关启动中... && echo   端口: 8080 && echo   数据库: %DB_HOST%:%DB_PORT%/%DB_NAME% && echo   Swagger: http://localhost:8080/swagger/index.html && echo. && go run main.go"
    timeout /t 3
) else (
    echo ❌ API网关文件不存在: services\api-gateway\main.go
)

echo.
echo ⏳ 等待所有服务启动完成...
timeout /t 25

echo.
echo 🌐 正在打开Swagger文档页面...
echo.

:: 打开Swagger页面
start http://localhost:8085/swagger/index.html
timeout /t 2
start http://localhost:8082/swagger/index.html
timeout /t 2
start http://localhost:8083/swagger/index.html
timeout /t 2
start http://localhost:8084/swagger/index.html
timeout /t 2
start http://localhost:8080/swagger/index.html

echo.
echo =====================================
echo   🎉 微服务集群启动完成！
echo =====================================
echo.
echo 📊 服务状态：
echo.
echo 🌐 服务端点：
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
echo 🔧 数据库配置：
echo   ├─ 地址: %DB_HOST%:%DB_PORT%
echo   ├─ 用户: %DB_USER%
echo   ├─ 数据库: %DB_NAME%
echo   └─ 模式: %GIN_MODE%
echo.
echo 💡 提示：
echo   - 所有Swagger页面已自动打开
echo   - 如果服务启动失败，请检查MySQL连接
echo   - 关闭对应的CMD窗口可以停止服务
echo   - 如需修改数据库配置，请编辑此脚本
echo   - 网关会自动路由请求到对应的微服务
echo.

pause 