@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   🚀 Go微服务启动器 (非Docker模式)
echo =====================================
echo.

echo 📋 此模式将直接启动Go微服务，不依赖Docker容器
echo 💡 请确保已安装Go 1.21+ 和MySQL数据库
echo.

:: 检查Go环境
echo 🔍 检查Go环境...
go version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Go环境未安装或未配置
    echo.
    echo 💡 请先安装Go 1.21+：
    echo   下载地址: https://golang.org/dl/
    echo   安装后重启命令行
    echo.
    pause
    exit /b 1
)

echo ✅ Go环境检查通过
go version
echo.

:: 检查MySQL连接
echo 🔍 检查MySQL数据库连接...
echo 💡 请确保MySQL服务已启动，默认配置：
echo   地址: localhost:3306
echo   用户: root
echo   密码: root
echo   数据库: gin_dev
echo.

:: 设置环境变量
set DB_HOST=localhost
set DB_PORT=3306
set DB_USER=root
set DB_PASSWORD=root
set DB_NAME=gin_dev
set GIN_MODE=debug

echo 🔧 使用数据库配置：
echo   地址: %DB_HOST%:%DB_PORT%
echo   用户: %DB_USER%
echo   数据库: %DB_NAME%
echo.

:: 询问是否继续
echo ⚠️  注意：此模式需要手动启动MySQL数据库
echo.
set /p confirm=是否继续启动Go微服务？(y/n): 
if /i not "%confirm%"=="y" (
    echo 已取消启动
    pause
    exit /b 0
)

echo.
echo 🚀 开始启动Go微服务...
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
echo ⏳ 等待服务启动完成...
timeout /t 15

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
echo   🎉 Go微服务启动完成！(非Docker模式)
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
echo 🔧 数据库配置：
echo   ├─ 地址: %DB_HOST%:%DB_PORT%
echo   ├─ 用户: %DB_USER%
echo   ├─ 数据库: %DB_NAME%
echo   └─ 模式: 非Docker模式
echo.
echo 💡 提示：
echo   - 所有Swagger页面已自动打开
echo   - 如果服务启动失败，请检查MySQL连接
echo   - 关闭对应的CMD窗口可以停止服务
echo   - 如需修改数据库配置，请编辑此脚本
echo.

pause 