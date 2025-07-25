@echo off
echo ====================================
echo   启动 Gin MVC Docker 服务
echo ====================================

echo.
echo 正在检查 Docker 状态...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] Docker 未安装或未启动
    echo 请确保 Docker Desktop 已安装并运行
    pause
    exit /b 1
)

echo 正在检查 docker-compose...
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] docker-compose 未安装
    pause
    exit /b 1
)

echo.
echo 正在启动服务...
docker-compose up -d

echo.
echo 等待服务启动...
timeout /t 10

echo.
echo 检查服务状态...
docker-compose ps

echo.
echo ====================================
echo   服务启动完成！
echo ====================================
echo.
echo 应用地址: http://localhost:8080
echo Swagger文档: http://localhost:8080/swagger/index.html
echo 数据库地址: localhost:3306
echo.
echo 查看日志: docker-compose logs -f
echo 停止服务: docker-compose down
echo.
pause 