@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   🚀 Go Shop 开发环境 (DEV) 启动
echo =====================================

:: 设置环境变量
set ENVIRONMENT=dev
set ENV_FILE=..\config\dev.env

echo 🔧 当前环境: 开发环境 (DEV)
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

docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] Docker未安装，请先安装Docker Desktop
    pause
    exit /b 1
)

echo ✅ 运行环境检查通过
echo.

:: 第一步：启动基础设施
echo 🔧 第一步：启动开发环境基础设施...
echo   - MySQL数据库 (3307端口)
echo   - Redis缓存 (6379端口)
echo   - API网关 (8080端口)
echo   - Nginx代理 (80端口)
echo   - Prometheus (9090端口)
echo   - Grafana (3000端口)
echo.

cd /d "%~dp0.."
docker-compose -f docker\docker-compose.dev.yml up -d
if %errorlevel% neq 0 (
    echo [错误] 基础设施启动失败
    pause
    exit /b 1
)

echo ✅ 基础设施启动成功
echo ⏳ 等待数据库和Redis初始化...
timeout /t 30

:: 第二步：启动微服务
echo.
echo 🚀 第二步：启动开发环境微服务...
echo.

:: 启动用户服务 (8085端口)
echo 👥 启动用户服务 (8085端口)...
cd /d "%~dp0..\services\user-service"
go mod tidy >nul 2>&1
start "DEV-用户服务" cmd /k "set PORT=8085 && set DB_HOST=localhost && set DB_PORT=3307 && set DB_USER=gin_dev_user && set DB_PASSWORD=gin_dev_pass && set DB_NAME=gin_dev && set GIN_MODE=debug && go run main.go"
timeout /t 3

:: 启动产品服务 (8082端口)
echo 📦 启动产品服务 (8082端口)...
cd /d "%~dp0..\services\product-service"
go mod tidy >nul 2>&1
start "DEV-产品服务" cmd /k "set PORT=8082 && set DB_HOST=localhost && set DB_PORT=3307 && set DB_USER=gin_dev_user && set DB_PASSWORD=gin_dev_pass && set DB_NAME=gin_dev && set GIN_MODE=debug && go run main.go"
timeout /t 3

:: 启动购物车服务 (8083端口)
echo 🛒 启动购物车服务 (8083端口)...
cd /d "%~dp0..\services\cart-service"
go mod tidy >nul 2>&1
start "DEV-购物车服务" cmd /k "set PORT=8083 && set DB_HOST=localhost && set DB_PORT=3307 && set DB_USER=gin_dev_user && set DB_PASSWORD=gin_dev_pass && set DB_NAME=gin_dev && set GIN_MODE=debug && go run main.go"
timeout /t 3

:: 启动订单服务 (8084端口)
echo 📋 启动订单服务 (8084端口)...
cd /d "%~dp0..\services\order-service"
go mod tidy >nul 2>&1
start "DEV-订单服务" cmd /k "set PORT=8084 && set DB_HOST=localhost && set DB_PORT=3307 && set DB_USER=gin_dev_user && set DB_PASSWORD=gin_dev_pass && set DB_NAME=gin_dev && set GIN_MODE=debug && go run main.go"

:: 回到项目根目录
cd /d "%~dp0.."

echo.
echo ⏳ 等待所有服务启动完成...
timeout /t 30

echo.
echo =====================================
echo   🎉 开发环境启动完成！
echo =====================================
echo.
echo 🌐 开发环境访问地址：
echo   ┌─ 🏠 主页          │ http://localhost
echo   ├─ 🌐 API网关      │ http://localhost:8080
echo   ├─ 👥 用户服务     │ http://localhost:8085/health
echo   ├─ 📦 产品服务     │ http://localhost:8082/health
echo   ├─ 🛒 购物车服务   │ http://localhost:8083/health
echo   └─ 📋 订单服务     │ http://localhost:8084/health
echo.
echo 📊 监控和管理：
echo   ├─ 📈 Prometheus   │ http://localhost:9090
echo   ├─ 📊 Grafana      │ http://localhost:3000 (admin/dev_admin_123)
echo   └─ 🔧 健康检查     │ http://localhost:8080/health
echo.
echo 🔧 数据库信息 (开发环境)：
echo   ├─ MySQL: localhost:3307
echo   ├─ 数据库: gin_dev
echo   ├─ 用户: gin_dev_user
echo   ├─ 密码: gin_dev_pass
echo   └─ Redis: localhost:6379 (密码: dev_redis_123)
echo.
echo 🛠️ 开发环境管理命令：
echo   ├─ 查看Docker状态: docker-compose -f docker\docker-compose.dev.yml ps
echo   ├─ 停止基础设施: docker-compose -f docker\docker-compose.dev.yml down
echo   ├─ 查看日志: docker-compose -f docker\docker-compose.dev.yml logs -f
echo   └─ 关闭微服务窗口停止微服务
echo.
echo 💡 开发环境特性：
echo   - 调试模式开启，详细日志输出
echo   - 热重载支持，代码修改实时生效
echo   - 数据库和Redis独立于其他环境
echo   - 包含完整监控和日志收集系统
echo.

pause 