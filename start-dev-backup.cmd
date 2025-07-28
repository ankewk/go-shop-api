@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   🚀 Go Shop 开发环境 (备用端口)
echo =====================================

:: 设置环境变量
set ENVIRONMENT=dev
set ENV_FILE=config\dev-backup.env

echo 🔧 当前环境: 开发环境 (使用备用端口)
echo 📋 环境配置: %ENV_FILE%
echo.

:: 检查环境配置文件
if not exist "%ENV_FILE%" (
    echo [错误] 环境配置文件不存在: %ENV_FILE%
    pause
    exit /b 1
)

:: 加载环境配置
for /f "tokens=*" %%i in (%ENV_FILE%) do (
    if not "%%i"=="" (
        if not "%%i:~0,1%"=="#" (
            set %%i
        )
    )
)

echo ✅ 环境配置加载完成
echo.

:: 检查运行环境
echo 正在检查运行环境...
go version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] Go环境未安装，请先安装Go 1.21+
    pause
    exit /b 1
)

echo ✅ 运行环境检查通过
echo.

:: 检查Docker容器是否已运行
echo 🔍 检查Docker容器状态...
docker ps | findstr gin-mysql-dev-backup >nul 2>&1
if %errorlevel% neq 0 (
    echo [警告] 未发现Docker容器，请先运行修复脚本
    echo 💡 请运行: quick-fix-docker.cmd
    pause
    exit /b 1
)

echo ✅ Docker容器运行正常
echo.

:: 启动微服务
echo 🚀 启动开发环境微服务...
echo.

:: 启动用户服务 (8085端口)
echo 👥 启动用户服务 (8085端口)...
cd /d "%~dp0..\services\user-service"
go mod tidy >nul 2>&1
start "DEV-用户服务-备用" cmd /k "set PORT=8085 && set DB_HOST=localhost && set DB_PORT=3308 && set DB_USER=gin_dev_user && set DB_PASSWORD=gin_dev_pass && set DB_NAME=gin_dev && set GIN_MODE=debug && go run main.go"
timeout /t 3

:: 启动产品服务 (8082端口)
echo 📦 启动产品服务 (8082端口)...
cd /d "%~dp0..\services\product-service"
go mod tidy >nul 2>&1
start "DEV-产品服务-备用" cmd /k "set PORT=8082 && set DB_HOST=localhost && set DB_PORT=3308 && set DB_USER=gin_dev_user && set DB_PASSWORD=gin_dev_pass && set DB_NAME=gin_dev && set GIN_MODE=debug && go run main.go"
timeout /t 3

:: 启动购物车服务 (8083端口)
echo 🛒 启动购物车服务 (8083端口)...
cd /d "%~dp0..\services\cart-service"
go mod tidy >nul 2>&1
start "DEV-购物车服务-备用" cmd /k "set PORT=8083 && set DB_HOST=localhost && set DB_PORT=3308 && set DB_USER=gin_dev_user && set DB_PASSWORD=gin_dev_pass && set DB_NAME=gin_dev && set GIN_MODE=debug && go run main.go"
timeout /t 3

:: 启动订单服务 (8084端口)
echo 📋 启动订单服务 (8084端口)...
cd /d "%~dp0..\services\order-service"
go mod tidy >nul 2>&1
start "DEV-订单服务-备用" cmd /k "set PORT=8084 && set DB_HOST=localhost && set DB_PORT=3308 && set DB_USER=gin_dev_user && set DB_PASSWORD=gin_dev_pass && set DB_NAME=gin_dev && set GIN_MODE=debug && go run main.go"

:: 回到项目根目录
cd /d "%~dp0.."

echo.
echo ⏳ 等待所有服务启动完成...
timeout /t 30

echo.
echo =====================================
echo   🎉 开发环境启动完成！(备用端口)
echo =====================================
echo.
echo 🌐 服务访问地址：
echo   ├─ 👥 用户服务     │ http://localhost:8085/health
echo   ├─ 📦 产品服务     │ http://localhost:8082/health
echo   ├─ 🛒 购物车服务   │ http://localhost:8083/health
echo   └─ 📋 订单服务     │ http://localhost:8084/health
echo.
echo 🔧 数据库信息 (备用端口)：
echo   ├─ MySQL: localhost:3308 (注意端口!)
echo   ├─ 数据库: gin_dev
echo   ├─ 用户: gin_dev_user
echo   ├─ 密码: gin_dev_pass
echo   └─ Redis: localhost:6380 (注意端口!)
echo.
echo 💡 重要提示：
echo   - 使用的是备用端口配置
echo   - MySQL端口: 3308 (不是3307)
echo   - Redis端口: 6380 (不是6379)
echo   - 请确保应用连接正确的端口
echo.
echo 🛠️ 管理命令：
echo   ├─ 查看Docker容器: docker ps
echo   ├─ 停止容器: docker stop gin-mysql-dev-backup gin-redis-dev-backup
echo   └─ 关闭微服务窗口停止微服务
echo.

pause 