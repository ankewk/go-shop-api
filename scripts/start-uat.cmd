@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   🚀 Go Shop UAT环境 (UAT) 启动
echo =====================================

:: 设置环境变量
set ENVIRONMENT=uat
set ENV_FILE=..\config\uat.env

echo 🔧 当前环境: UAT环境 (用户接受测试)
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
echo 🔧 第一步：启动UAT环境基础设施...
echo   - MySQL数据库 (3308端口)
echo   - Redis缓存 (6380端口)
echo   - API网关 (9080端口)
echo   - Nginx代理 (8180端口)
echo   - Prometheus (9091端口)
echo   - Grafana (3001端口)
echo   - Elasticsearch (9200端口)
echo.

cd /d "%~dp0.."
docker-compose -f docker\docker-compose.uat.yml up -d
if %errorlevel% neq 0 (
    echo [错误] 基础设施启动失败
    pause
    exit /b 1
)

echo ✅ 基础设施启动成功
echo ⏳ 等待数据库和Redis初始化...
timeout /t 45

:: 第二步：启动微服务
echo.
echo 🚀 第二步：启动UAT环境微服务...
echo.

:: 启动用户服务 (9085端口)
echo 👥 启动用户服务 (9085端口)...
cd /d "%~dp0..\services\user-service"
go mod tidy >nul 2>&1
start "UAT-用户服务" cmd /k "set PORT=9085 && set DB_HOST=localhost && set DB_PORT=3308 && set DB_USER=gin_uat_user && set DB_PASSWORD=gin_uat_pass && set DB_NAME=gin_uat && set GIN_MODE=release && go run main.go"
timeout /t 5

:: 启动产品服务 (9082端口)
echo 📦 启动产品服务 (9082端口)...
cd /d "%~dp0..\services\product-service"
go mod tidy >nul 2>&1
start "UAT-产品服务" cmd /k "set PORT=9082 && set DB_HOST=localhost && set DB_PORT=3308 && set DB_USER=gin_uat_user && set DB_PASSWORD=gin_uat_pass && set DB_NAME=gin_uat && set GIN_MODE=release && go run main.go"
timeout /t 5

:: 启动购物车服务 (9083端口)
echo 🛒 启动购物车服务 (9083端口)...
cd /d "%~dp0..\services\cart-service"
go mod tidy >nul 2>&1
start "UAT-购物车服务" cmd /k "set PORT=9083 && set DB_HOST=localhost && set DB_PORT=3308 && set DB_USER=gin_uat_user && set DB_PASSWORD=gin_uat_pass && set DB_NAME=gin_uat && set GIN_MODE=release && go run main.go"
timeout /t 5

:: 启动订单服务 (9084端口)
echo 📋 启动订单服务 (9084端口)...
cd /d "%~dp0..\services\order-service"
go mod tidy >nul 2>&1
start "UAT-订单服务" cmd /k "set PORT=9084 && set DB_HOST=localhost && set DB_PORT=3308 && set DB_USER=gin_uat_user && set DB_PASSWORD=gin_uat_pass && set DB_NAME=gin_uat && set GIN_MODE=release && go run main.go"

:: 回到项目根目录
cd /d "%~dp0.."

echo.
echo ⏳ 等待所有服务启动完成...
timeout /t 45

echo.
echo =====================================
echo   🎉 UAT环境启动完成！
echo =====================================
echo.
echo 🌐 UAT环境访问地址：
echo   ┌─ 🏠 主页          │ http://localhost:8180
echo   ├─ 🌐 API网关      │ http://localhost:9080
echo   ├─ 👥 用户服务     │ http://localhost:9085/health
echo   ├─ 📦 产品服务     │ http://localhost:9082/health
echo   ├─ 🛒 购物车服务   │ http://localhost:9083/health
echo   └─ 📋 订单服务     │ http://localhost:9084/health
echo.
echo 📊 监控和管理：
echo   ├─ 📈 Prometheus   │ http://localhost:9091
echo   ├─ 📊 Grafana      │ http://localhost:3001 (admin/uat_admin_456)
echo   ├─ 🔍 Elasticsearch│ http://localhost:9200
echo   └─ 🔧 健康检查     │ http://localhost:9080/health
echo.
echo 🔧 数据库信息 (UAT环境)：
echo   ├─ MySQL: localhost:3308
echo   ├─ 数据库: gin_uat
echo   ├─ 用户: gin_uat_user
echo   ├─ 密码: gin_uat_pass
echo   └─ Redis: localhost:6380 (密码: uat_redis_456)
echo.
echo 🛠️ UAT环境管理命令：
echo   ├─ 查看Docker状态: docker-compose -f docker\docker-compose.uat.yml ps
echo   ├─ 停止基础设施: docker-compose -f docker\docker-compose.uat.yml down
echo   ├─ 查看日志: docker-compose -f docker\docker-compose.uat.yml logs -f
echo   └─ 关闭微服务窗口停止微服务
echo.
echo 💡 UAT环境特性：
echo   - 生产级配置，性能优化
echo   - 完整日志收集和监控
echo   - 数据库和缓存独立于开发环境
echo   - 支持用户接受测试和性能测试
echo   - 包含Elasticsearch日志分析
echo.

pause 