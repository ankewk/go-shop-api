@echo off
echo ====================================
echo   启动开发环境 Docker 服务
echo ====================================

echo.
echo 正在启动开发环境服务...
echo 使用端口 3307 (MySQL) 和 8080 (APP)
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d

echo.
echo 等待服务启动...
timeout /t 15

echo.
echo 检查服务状态...
docker-compose ps

echo.
echo ====================================
echo   开发环境启动完成！
echo ====================================
echo.
echo 应用地址: http://localhost:8080
echo Swagger文档: http://localhost:8080/swagger/index.html
echo MySQL端口: 3307 (避免本地MySQL冲突)
echo 数据库: gin_dev
echo 用户: gin_dev / gin_dev
echo.
echo 查看日志: docker-compose logs -f app
echo 进入应用容器: docker exec -it gin-app sh
echo.
pause 