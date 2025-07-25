@echo off
echo ====================================
echo   停止 Gin MVC Docker 服务
echo ====================================

echo.
echo 正在停止服务...
docker-compose down

echo.
echo 检查容器状态...
docker-compose ps

echo.
echo ====================================
echo   服务已停止！
echo ====================================
echo.
echo 如需清理数据卷，请运行:
echo docker-compose down -v
echo.
echo 如需重建镜像，请运行:
echo docker-compose build --no-cache
echo.
pause 