@echo off
chcp 65001 >nul 2>&1

:MAIN_MENU
cls
echo =====================================
echo   🌍 Go Shop 多环境管理平台
echo =====================================
echo.
echo   当前项目支持三个环境的独立部署：
echo.
echo   🔧 DEV  - 开发环境 (调试优化)
echo   🧪 UAT  - 测试环境 (用户验收)  
echo   🚀 PROD - 生产环境 (高可用)
echo.
echo =====================================
echo   请选择操作:
echo =====================================
echo.
echo   【 环境启动 】
echo   1. 🔧 启动开发环境 (DEV)
echo   2. 🧪 启动测试环境 (UAT)
echo   3. 🚀 启动生产环境 (PROD)
echo   0. 🛠️ 一键启动开发环境 (自动修复网络问题)
echo.
echo   【 网络修复 】
echo   Q. ⚡ 快速修复Docker网络问题
echo   I. 🌐 修复Docker网络IP冲突问题
echo.
echo   【 故障诊断 】
echo   S. 🔍 启动问题诊断 (推荐首选)
echo   M. 📖 查看手动启动指南
echo.
echo   【 数据库工具 】
echo   D. 🔧 数据库连接问题诊断
echo   G. 🚀 启动Go微服务
echo   W. 📖 打开Swagger文档
echo.
echo   【 本地启动 】
echo   L. 🏠 本地启动器 (推荐)
echo   N. 🚀 启动Go微服务(非Docker)
echo.
echo   【 环境管理 】
echo   4. 📊 检查所有环境状态
echo   5. 🛑 停止指定环境
echo   6. 🧹 清理所有环境
echo.
echo   【 信息查看 】
echo   8. 📋 查看环境配置对比
echo   9. 📖 查看帮助文档
echo   X. ❌ 退出程序
echo.
set /p choice=请输入选项 (0-9,B,Q,I,S,M,E,D,G,W,N,S,X): 

if "%choice%"=="1" goto START_DEV
if "%choice%"=="2" goto START_UAT
if "%choice%"=="3" goto START_PROD
if "%choice%"=="0" goto START_DEV_AUTO
if /i "%choice%"=="Q" goto QUICK_FIX
if /i "%choice%"=="I" goto FIX_IP_CONFLICT
if /i "%choice%"=="S" goto STARTUP_DIAGNOSIS
if /i "%choice%"=="M" goto SHOW_MANUAL_GUIDE

if /i "%choice%"=="D" goto DATABASE_DIAGNOSIS
if /i "%choice%"=="G" goto START_GO_SERVICES
if /i "%choice%"=="W" goto OPEN_SWAGGER
if /i "%choice%"=="L" goto START_LOCAL
if /i "%choice%"=="N" goto START_NO_DOCKER

if "%choice%"=="4" goto CHECK_ALL
if "%choice%"=="5" goto STOP_ENV
if "%choice%"=="6" goto CLEAN_ALL
if "%choice%"=="8" goto SHOW_CONFIG
if "%choice%"=="9" goto SHOW_HELP
if /i "%choice%"=="X" goto EXIT

echo 无效选项，请重新选择...
timeout /t 2
goto MAIN_MENU

:START_DEV
echo.
echo 🔧 正在启动开发环境 (DEV)...
call scripts\start-dev.cmd
goto MAIN_MENU

:START_UAT
echo.
echo 🧪 正在启动测试环境 (UAT)...
call scripts\start-uat.cmd
goto MAIN_MENU

:START_PROD
echo.
echo 🚀 正在启动生产环境 (PROD)...
call scripts\start-prod.cmd
goto MAIN_MENU

:START_DEV_AUTO
echo.
echo 🛠️ 正在一键启动开发环境 (自动修复网络问题)...
call start-dev-auto.cmd
goto MAIN_MENU



:QUICK_FIX
echo.
echo ⚡ 正在快速修复Docker网络问题...
call quick-fix-docker.cmd
goto MAIN_MENU

:FIX_IP_CONFLICT
echo.
echo 🌐 正在修复Docker网络IP冲突问题...
call fix-network-ip-conflict.cmd
goto MAIN_MENU

:STARTUP_DIAGNOSIS
echo.
echo 🔍 正在进行启动问题诊断...
call startup-diagnosis.cmd
goto MAIN_MENU

:SHOW_MANUAL_GUIDE
echo.
echo 📖 正在打开手动启动指南...
start notepad manual-startup-guide.md
echo ✅ 手动启动指南已在记事本中打开
echo.
pause
goto MAIN_MENU



:DATABASE_DIAGNOSIS
echo.
echo 🔧 正在进行数据库连接诊断...
call database-connection-fix.cmd
goto MAIN_MENU

:START_GO_SERVICES
echo.
echo 🚀 正在启动Go微服务...
call start-services-no-docker.cmd
goto MAIN_MENU

:OPEN_SWAGGER
echo.
echo 📖 正在打开Swagger文档...
call open-swagger.cmd
goto MAIN_MENU

:START_LOCAL
echo.
echo 🏠 正在启动本地启动器...
call start-local.cmd
goto MAIN_MENU

:START_NO_DOCKER
echo.
echo 🚀 正在启动Go微服务(非Docker模式)...
call start-services-no-docker.cmd
goto MAIN_MENU



:CHECK_ALL
cls
echo =====================================
echo   📊 所有环境状态检查
echo =====================================
echo.

echo 🔧 开发环境 (DEV) 状态：
echo ----------------------------------------
netstat -ano | findstr ":8080" >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✅ API网关 (8080) - 运行中
) else (
    echo   ❌ API网关 (8080) - 未启动
)

netstat -ano | findstr ":3307" >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✅ MySQL (3307) - 运行中
) else (
    echo   ❌ MySQL (3307) - 未启动
)

netstat -ano | findstr ":6379" >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✅ Redis (6379) - 运行中
) else (
    echo   ❌ Redis (6379) - 未启动
)

echo.
echo 🧪 测试环境 (UAT) 状态：
echo ----------------------------------------
netstat -ano | findstr ":9080" >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✅ API网关 (9080) - 运行中
) else (
    echo   ❌ API网关 (9080) - 未启动
)

netstat -ano | findstr ":3308" >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✅ MySQL (3308) - 运行中
) else (
    echo   ❌ MySQL (3308) - 未启动
)

echo.
echo 🚀 生产环境 (PROD) 状态：
echo ----------------------------------------
netstat -ano | findstr ":7080" >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✅ API网关-1 (7080) - 运行中
) else (
    echo   ❌ API网关-1 (7080) - 未启动
)

netstat -ano | findstr ":7081" >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✅ API网关-2 (7081) - 运行中
) else (
    echo   ❌ API网关-2 (7081) - 未启动
)

netstat -ano | findstr ":3309" >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✅ MySQL主库 (3309) - 运行中
) else (
    echo   ❌ MySQL主库 (3309) - 未启动
)

echo.
pause
goto MAIN_MENU

:STOP_ENV
cls
echo =====================================
echo   🛑 停止指定环境
echo =====================================
echo.
echo 请选择要停止的环境：
echo.
echo   1. 停止开发环境 (DEV)
echo   2. 停止测试环境 (UAT)
echo   3. 停止生产环境 (PROD)
echo   4. 返回主菜单
echo.
set /p stop_choice=请输入选项 (1-4): 

if "%stop_choice%"=="1" (
    echo 正在停止开发环境...
    docker-compose -f docker\docker-compose.dev.yml down
    taskkill /fi "WINDOWTITLE eq DEV-*" /f >nul 2>&1
    echo ✅ 开发环境已停止
)
if "%stop_choice%"=="2" (
    echo 正在停止测试环境...
    docker-compose -f docker\docker-compose.uat.yml down
    taskkill /fi "WINDOWTITLE eq UAT-*" /f >nul 2>&1
    echo ✅ 测试环境已停止
)
if "%stop_choice%"=="3" (
    echo 正在停止生产环境...
    docker-compose -f docker\docker-compose.prod.yml down
    taskkill /fi "WINDOWTITLE eq PROD-*" /f >nul 2>&1
    echo ✅ 生产环境已停止
)
if "%stop_choice%"=="4" goto MAIN_MENU

pause
goto MAIN_MENU

:CLEAN_ALL
echo.
echo ⚠️  警告：此操作将停止并清理所有环境！
set /p confirm=请确认是否继续？(Y/N): 
if /i not "%confirm%"=="Y" goto MAIN_MENU

echo 正在清理所有环境...
docker-compose -f docker\docker-compose.dev.yml down
docker-compose -f docker\docker-compose.uat.yml down
docker-compose -f docker\docker-compose.prod.yml down
taskkill /f /im go.exe >nul 2>&1
docker system prune -f
echo ✅ 所有环境已清理完成
pause
goto MAIN_MENU

:SHOW_CONFIG
cls
echo =====================================
echo   📋 环境配置对比
echo =====================================
echo.
echo | set /p="环境特性              │ 开发环境(DEV) │ 测试环境(UAT) │ 生产环境(PROD)"
echo.
echo =====================================================================
echo | set /p="API网关端口          │ 8080          │ 9080          │ 7080,7081"
echo.
echo | set /p="MySQL端口            │ 3307          │ 3308          │ 3309,3310"
echo.
echo | set /p="Redis端口            │ 6379          │ 6380          │ 6381"
echo.
echo | set /p="运行模式             │ debug         │ release       │ release"
echo.
echo | set /p="日志级别             │ debug         │ info          │ warn"
echo.
echo | set /p="数据库架构           │ 单机          │ 单机          │ 主从"
echo.
echo | set /p="缓存架构             │ 单机          │ 单机          │ 集群"
echo.
echo | set /p="负载均衡             │ 无            │ 无            │ Nginx"
echo.
echo | set /p="SSL支持              │ 无            │ 无            │ 有"
echo.
echo | set /p="监控系统             │ 基础          │ 增强          │ 完整"
echo.
echo | set /p="日志收集             │ 无            │ ELK           │ ELK"
echo.
echo | set /p="消息队列             │ 无            │ 无            │ RabbitMQ"
echo.
echo | set /p="资源限制             │ 低            │ 中            │ 高"
echo.
echo =====================================================================
echo.
pause
goto MAIN_MENU

:SHOW_HELP
cls
echo =====================================
echo   📖 Go Shop 多环境帮助文档
echo =====================================
echo.
echo 🏗️ 系统架构：
echo   本系统采用微服务架构，支持多环境独立部署
echo.
echo 🌍 环境说明：
echo   ├─ DEV  (开发环境): 用于日常开发和调试
echo   ├─ UAT  (测试环境): 用于用户接受测试和集成测试
echo   └─ PROD (生产环境): 用于正式生产运行
echo.
echo 📦 服务组件：
echo   ├─ MySQL数据库    │ 数据持久化存储
echo   ├─ Redis缓存      │ 会话和数据缓存
echo   ├─ API网关        │ 统一入口和路由
echo   ├─ 用户服务       │ 用户管理和认证
echo   ├─ 产品服务       │ 商品管理和库存
echo   ├─ 购物车服务     │ 购物车操作
echo   ├─ 订单服务       │ 订单处理和支付
echo   ├─ Nginx          │ 反向代理和负载均衡
echo   ├─ Prometheus     │ 指标监控和采集
echo   ├─ Grafana        │ 可视化监控面板
echo   ├─ Elasticsearch  │ 日志搜索和分析
echo   └─ RabbitMQ       │ 消息队列 (仅生产环境)
echo.
echo 🎮 使用流程：
echo   1. 选择对应环境启动
echo   2. 等待所有服务启动完成
echo   3. 通过浏览器访问应用
echo   4. 使用监控系统查看状态
echo   5. 开发完成后停止环境
echo.
echo 🔧 技术要求：
echo   - Go 1.21+ 开发环境
echo   - Docker Desktop 容器运行
echo   - 8GB+ 内存 (推荐16GB)
echo   - 20GB+ 磁盘空间
echo.
echo 📞 技术支持：
echo   - 项目文档: README.md
echo   - 配置文件: config/ 目录
echo   - 日志文件: logs/ 目录
echo   - Docker配置: docker/ 目录
echo.
pause
goto MAIN_MENU

:EXIT
echo.
echo 👋 感谢使用 Go Shop 多环境管理平台！
echo.
pause
exit 