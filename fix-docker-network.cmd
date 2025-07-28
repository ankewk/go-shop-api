@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   🔧 Docker 网络问题修复工具
echo =====================================
echo.

echo 🔍 第一步：检查Docker状态...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] Docker未运行或未安装
    echo.
    echo 💡 解决方案：
    echo   1. 启动 Docker Desktop
    echo   2. 等待Docker完全启动（托盘图标变成绿色）
    echo   3. 重新运行此脚本
    echo.
    pause
    exit /b 1
)

echo ✅ Docker 已安装并运行
echo.

echo 🧹 第二步：清理冲突容器和网络...

:: 停止可能冲突的容器
echo 停止所有相关容器...
docker-compose -f docker\docker-compose.dev.yml down >nul 2>&1
docker-compose -f docker\docker-compose.uat.yml down >nul 2>&1
docker-compose -f docker\docker-compose.prod.yml down >nul 2>&1

:: 删除可能存在的旧容器
echo 删除旧容器...
docker rm gin-mysql-dev gin-redis-dev gin-api-gateway-dev gin-nginx-dev gin-prometheus-dev gin-grafana-dev >nul 2>&1

:: 清理网络
echo 清理Docker网络...
docker network prune -f >nul 2>&1

:: 清理卷
echo 清理未使用的卷...
docker volume prune -f >nul 2>&1

echo ✅ 清理完成
echo.

echo 🔍 第三步：检查端口占用...
echo 检查关键端口状态：

netstat -ano | findstr ":3307" >nul 2>&1
if %errorlevel% equ 0 (
    echo   ❌ 3307端口被占用 (MySQL)
    echo   请手动停止占用此端口的进程
) else (
    echo   ✅ 3307端口空闲 (MySQL)
)

netstat -ano | findstr ":8080" >nul 2>&1
if %errorlevel% equ 0 (
    echo   ❌ 8080端口被占用 (API网关)
    echo   请手动停止占用此端口的进程
) else (
    echo   ✅ 8080端口空闲 (API网关)
)

netstat -ano | findstr ":6379" >nul 2>&1
if %errorlevel% equ 0 (
    echo   ❌ 6379端口被占用 (Redis)
    echo   请手动停止占用此端口的进程
) else (
    echo   ✅ 6379端口空闲 (Redis)
)

echo.

echo 🔄 第四步：重置Docker网络...
docker network create go-shop-dev-network >nul 2>&1

echo.
echo 🚀 第五步：尝试启动开发环境...
echo.

docker-compose -f docker\docker-compose.dev.yml up -d

if %errorlevel% equ 0 (
    echo ✅ 开发环境启动成功！
    echo.
    echo 📊 检查容器状态：
    docker-compose -f docker\docker-compose.dev.yml ps
    echo.
    echo 🌐 访问地址：
    echo   - API网关: http://localhost:8080/health
    echo   - 监控面板: http://localhost:9090
    echo   - 可视化监控: http://localhost:3000
) else (
    echo ❌ 启动失败，请查看错误信息
    echo.
    echo 💡 可能的解决方案：
    echo   1. 重启 Docker Desktop
    echo   2. 重启计算机
    echo   3. 检查防火墙设置
    echo   4. 尝试更换端口配置
)

echo.
pause 