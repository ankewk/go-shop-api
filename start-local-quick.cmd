@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   ⚡ Go Shop 快速本地启动
echo =====================================
echo.

echo 🚀 快速启动本地开发环境...
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

:: 检查MySQL连接
echo 🔍 检查MySQL连接...
netstat -ano | findstr ":3306" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 检测到MySQL服务运行在3306端口
    set DB_HOST=localhost
    set DB_PORT=3306
    set DB_USER=root
    set DB_PASSWORD=root
    set DB_NAME=gin_dev
) else (
    echo 🐳 未检测到MySQL，启动Docker MySQL...
    docker run -d --name mysql-local -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=gin_dev mysql:8.0
    echo ⏳ 等待MySQL初始化...
    timeout /t 30
    set DB_HOST=localhost
    set DB_PORT=3306
    set DB_USER=root
    set DB_PASSWORD=root
    set DB_NAME=gin_dev
)

:: 设置环境变量
set GIN_MODE=debug
set LOG_LEVEL=debug
set PORT=8080

:: 下载依赖
echo 📦 下载Go依赖...
go mod tidy
if %errorlevel% neq 0 (
    echo ❌ 依赖下载失败
    pause
    exit /b 1
)

:: 启动应用
echo 🚀 启动Go Shop应用...
echo.
echo 📋 启动配置：
echo   - 数据库: %DB_HOST%:%DB_PORT%/%DB_NAME%
echo   - 用户: %DB_USER%
echo   - 模式: %GIN_MODE%
echo   - 端口: %PORT%
echo.
echo 💡 服务将在 http://localhost:%PORT% 启动
echo 💡 Swagger文档: http://localhost:%PORT%/swagger/index.html
echo.

:: 启动应用
go run main.go

pause 