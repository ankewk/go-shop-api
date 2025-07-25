@echo off
echo ====================================
echo   重建 Gin MVC Docker 服务
echo ====================================

echo.
echo 正在停止现有服务...
docker-compose down

echo.
echo 正在重建镜像...
docker-compose build --no-cache

echo.
echo 正在启动服务...
docker-compose up -d

echo.
echo 等待服务启动...
timeout /t 15

echo.
echo 检查服务状态...
docker-compose ps

echo.
echo ====================================
echo   重建完成！
echo ====================================
echo.
echo 应用地址: http://localhost:8080
echo Swagger文档: http://localhost:8080/swagger/index.html
echo.
pause 