@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   📖 打开所有服务的Swagger文档
echo =====================================
echo.

echo 🔍 检查服务状态并打开Swagger...
echo.

:: 检查并打开用户服务Swagger
echo 👥 检查用户服务 (8085)...
curl -s http://localhost:8085/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 用户服务运行中 - 打开Swagger
    start http://localhost:8085/swagger/index.html
    timeout /t 1
) else (
    echo ❌ 用户服务未启动
)

:: 检查并打开产品服务Swagger
echo 📦 检查产品服务 (8082)...
curl -s http://localhost:8082/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 产品服务运行中 - 打开Swagger
    start http://localhost:8082/swagger/index.html
    timeout /t 1
) else (
    echo ❌ 产品服务未启动
)

:: 检查并打开购物车服务Swagger
echo 🛒 检查购物车服务 (8083)...
curl -s http://localhost:8083/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 购物车服务运行中 - 打开Swagger
    start http://localhost:8083/swagger/index.html
    timeout /t 1
) else (
    echo ❌ 购物车服务未启动
)

:: 检查并打开订单服务Swagger
echo 📋 检查订单服务 (8084)...
curl -s http://localhost:8084/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 订单服务运行中 - 打开Swagger
    start http://localhost:8084/swagger/index.html
    timeout /t 1
) else (
    echo ❌ 订单服务未启动
)

:: 检查并打开API网关Swagger
echo 🌐 检查API网关 (8080)...
curl -s http://localhost:8080/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ API网关运行中 - 打开Swagger
    start http://localhost:8080/swagger/index.html
    timeout /t 1
) else (
    echo ❌ API网关未启动
)

echo.
echo =====================================
echo   📖 Swagger文档页面已打开
echo =====================================
echo.
echo 🌐 如果页面未加载，请等待服务完全启动后手动访问：
echo.
echo   👥 用户服务: http://localhost:8085/swagger/index.html
echo   📦 产品服务: http://localhost:8082/swagger/index.html
echo   🛒 购物车服务: http://localhost:8083/swagger/index.html
echo   📋 订单服务: http://localhost:8084/swagger/index.html
echo   🌐 API网关: http://localhost:8080/swagger/index.html
echo.

pause 