@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   🚀 Go Shop 生产环境 (PROD) 启动
echo =====================================

:: 设置环境变量
set ENVIRONMENT=prod
set ENV_FILE=..\config\prod.env

echo 🔧 当前环境: 生产环境 (PRODUCTION)
echo 📋 环境配置: %ENV_FILE%
echo.

:: 安全确认
echo ⚠️  警告：您即将启动生产环境！
echo.
echo 生产环境包含以下关键特性：
echo   - 高可用数据库主从配置
echo   - Redis集群缓存
echo   - API网关负载均衡
echo   - SSL安全连接
echo   - 完整监控和日志系统
echo   - 消息队列支持
echo.
set /p confirm=请确认是否继续启动生产环境？(Y/N): 
if /i not "%confirm%"=="Y" (
    echo 取消启动生产环境
    pause
    exit /b 0
)

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
echo 正在检查生产环境运行条件...
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

:: 检查系统资源
echo 检查系统资源...
wmic OS get TotalPhysicalMemory /value >nul 2>&1
if %errorlevel% neq 0 (
    echo [警告] 无法检查系统内存，建议确保至少8GB可用内存
)

echo ✅ 运行环境检查通过
echo.

:: 第一步：启动基础设施
echo 🔧 第一步：启动生产环境基础设施...
echo   - MySQL主从数据库 (3309,3310端口)
echo   - Redis集群 (6381端口)
echo   - API网关集群 (7080,7081端口)
echo   - Nginx负载均衡 (443,8080端口)
echo   - Prometheus (9092端口)
echo   - Grafana (3002端口)
echo   - Elasticsearch (9201端口)
echo   - RabbitMQ (5672,15672端口)
echo.

cd /d "%~dp0.."
docker-compose -f docker\docker-compose.prod.yml up -d
if %errorlevel% neq 0 (
    echo [错误] 基础设施启动失败
    pause
    exit /b 1
)

echo ✅ 基础设施启动成功
echo ⏳ 等待数据库主从同步和集群初始化...
timeout /t 90

:: 第二步：启动微服务
echo.
echo 🚀 第二步：启动生产环境微服务...
echo.

:: 启动用户服务 (7085端口)
echo 👥 启动用户服务 (7085端口)...
cd /d "%~dp0..\services\user-service"
go mod tidy >nul 2>&1
start "PROD-用户服务" cmd /k "set PORT=7085 && set DB_HOST=localhost && set DB_PORT=3309 && set DB_USER=gin_prod_user && set DB_PASSWORD=gin_prod_pass_secure && set DB_NAME=gin_prod && set GIN_MODE=release && go run main.go"
timeout /t 8

:: 启动产品服务 (7082端口)
echo 📦 启动产品服务 (7082端口)...
cd /d "%~dp0..\services\product-service"
go mod tidy >nul 2>&1
start "PROD-产品服务" cmd /k "set PORT=7082 && set DB_HOST=localhost && set DB_PORT=3309 && set DB_USER=gin_prod_user && set DB_PASSWORD=gin_prod_pass_secure && set DB_NAME=gin_prod && set GIN_MODE=release && go run main.go"
timeout /t 8

:: 启动购物车服务 (7083端口)
echo 🛒 启动购物车服务 (7083端口)...
cd /d "%~dp0..\services\cart-service"
go mod tidy >nul 2>&1
start "PROD-购物车服务" cmd /k "set PORT=7083 && set DB_HOST=localhost && set DB_PORT=3309 && set DB_USER=gin_prod_user && set DB_PASSWORD=gin_prod_pass_secure && set DB_NAME=gin_prod && set GIN_MODE=release && go run main.go"
timeout /t 8

:: 启动订单服务 (7084端口)
echo 📋 启动订单服务 (7084端口)...
cd /d "%~dp0..\services\order-service"
go mod tidy >nul 2>&1
start "PROD-订单服务" cmd /k "set PORT=7084 && set DB_HOST=localhost && set DB_PORT=3309 && set DB_USER=gin_prod_user && set DB_PASSWORD=gin_prod_pass_secure && set DB_NAME=gin_prod && set GIN_MODE=release && go run main.go"

:: 回到项目根目录
cd /d "%~dp0.."

echo.
echo ⏳ 等待所有服务启动完成...
timeout /t 60

echo.
echo =====================================
echo   🎉 生产环境启动完成！
echo =====================================
echo.
echo 🌐 生产环境访问地址：
echo   ┌─ 🏠 主页(HTTPS)   │ https://localhost
echo   ├─ 🏠 主页(HTTP)    │ http://localhost:8080
echo   ├─ 🌐 API网关-1     │ http://localhost:7080
echo   ├─ 🌐 API网关-2     │ http://localhost:7081
echo   ├─ 👥 用户服务      │ http://localhost:7085/health
echo   ├─ 📦 产品服务      │ http://localhost:7082/health
echo   ├─ 🛒 购物车服务    │ http://localhost:7083/health
echo   └─ 📋 订单服务      │ http://localhost:7084/health
echo.
echo 📊 监控和管理：
echo   ├─ 📈 Prometheus    │ http://localhost:9092
echo   ├─ 📊 Grafana       │ http://localhost:3002 (admin/prod_admin_789_secure)
echo   ├─ 🔍 Elasticsearch │ http://localhost:9201
echo   ├─ 🐰 RabbitMQ      │ http://localhost:15672 (prod_rabbit_user/prod_rabbit_pass_secure)
echo   └─ 🔧 健康检查      │ http://localhost:7080/health
echo.
echo 🔧 数据库信息 (生产环境)：
echo   ├─ MySQL主库: localhost:3309
echo   ├─ MySQL从库: localhost:3310
echo   ├─ 数据库: gin_prod
echo   ├─ 用户: gin_prod_user
echo   ├─ 密码: gin_prod_pass_secure
echo   └─ Redis: localhost:6381 (密码: prod_redis_789_secure)
echo.
echo 🛠️ 生产环境管理命令：
echo   ├─ 查看Docker状态: docker-compose -f docker\docker-compose.prod.yml ps
echo   ├─ 停止基础设施: docker-compose -f docker\docker-compose.prod.yml down
echo   ├─ 查看日志: docker-compose -f docker\docker-compose.prod.yml logs -f
echo   ├─ 重启服务: docker-compose -f docker\docker-compose.prod.yml restart
echo   └─ 关闭微服务窗口停止微服务
echo.
echo 🛡️ 生产环境特性：
echo   - SSL/TLS加密传输
echo   - 数据库主从高可用架构
echo   - API网关负载均衡
echo   - Redis持久化存储
echo   - 完整监控报警系统
echo   - 日志收集和分析
echo   - 消息队列异步处理
echo   - 资源限制和性能优化
echo.
echo ⚠️  生产环境注意事项：
echo   - 请定期备份数据库
echo   - 监控系统资源使用情况
echo   - 及时查看日志和报警
echo   - 确保SSL证书有效性
echo.

pause 