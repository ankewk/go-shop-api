@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   停止 Go Shop Docker 微服务
echo =====================================

echo.
echo 正在停止微服务容器...

docker-compose -f docker-compose.microservices.yml down

echo.
echo 🧹 清理孤立的容器和网络...
docker system prune -f

echo.
echo =====================================
echo   ✅ 微服务已停止
echo =====================================
echo.
echo 📊 剩余容器：
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo.
pause 