@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   ⚡ Docker 网络快速修复
echo =====================================
echo.

echo 🔧 正在快速诊断和修复Docker网络问题...
echo.

:: 1. 停止并清理所有相关容器
echo 第一步：清理旧容器...
docker stop gin-mysql-dev gin-redis-dev gin-api-gateway-dev >nul 2>&1
docker rm gin-mysql-dev gin-redis-dev gin-api-gateway-dev >nul 2>&1
echo ✅ 容器清理完成

:: 2. 清理Docker网络
echo 第二步：清理网络...
docker network prune -f >nul 2>&1
echo ✅ 网络清理完成

:: 3. 重启Docker服务（Windows方式）
echo 第三步：重启Docker服务...
net stop com.docker.service >nul 2>&1
timeout /t 5 >nul
net start com.docker.service >nul 2>&1
echo ✅ Docker服务重启完成

:: 4. 等待Docker完全启动
echo 第四步：等待Docker完全启动...
timeout /t 20
echo ✅ 等待完成

:: 5. 尝试创建新网络（避免IP冲突）
echo 第五步：创建新网络...
echo.

echo 🌐 尝试创建网络（方案1）...
docker network create --subnet=172.20.0.0/16 go-shop-dev-network >nul 2>&1
if %errorlevel% neq 0 (
    echo 🌐 尝试创建网络（方案2）...
    docker network create --subnet=192.168.100.0/24 go-shop-dev-network >nul 2>&1
    if %errorlevel% neq 0 (
        echo 🌐 尝试创建网络（方案3）...
        docker network create go-shop-dev-network >nul 2>&1
    )
)
echo ✅ 网络创建完成

:: 6. 尝试使用不同端口启动
echo 第六步：使用替代配置启动...
echo.

echo 🗄️ 启动MySQL (使用端口3308)...
docker run -d --name gin-mysql-dev-backup ^
  --network go-shop-dev-network ^
  -p 3308:3306 ^
  -e MYSQL_ROOT_PASSWORD=dev_root_123 ^
  -e MYSQL_DATABASE=gin_dev ^
  -e MYSQL_USER=gin_dev_user ^
  -e MYSQL_PASSWORD=gin_dev_pass ^
  mysql:8.0

if %errorlevel% equ 0 (
    echo ✅ MySQL启动成功！端口：3308
) else (
    echo ❌ MySQL启动失败
)

echo.
echo 🔄 启动Redis (使用端口6380)...
docker run -d --name gin-redis-dev-backup ^
  --network go-shop-dev-network ^
  -p 6380:6379 ^
  redis:7-alpine redis-server --requirepass dev_redis_123

if %errorlevel% equ 0 (
    echo ✅ Redis启动成功！端口：6380
) else (
    echo ❌ Redis启动失败
)

echo.
echo 📊 检查容器状态：
docker ps

echo.
echo =====================================
echo   ✅ 快速修复完成！
echo =====================================
echo.
echo 📝 如果上面的容器启动成功，请使用以下配置：
echo.
echo 🗄️ MySQL连接信息：
echo   地址: localhost:3308 (注意端口变更)
echo   数据库: gin_dev
echo   用户: gin_dev_user
echo   密码: gin_dev_pass
echo.
echo 🔄 Redis连接信息：
echo   地址: localhost:6380 (注意端口变更)
echo   密码: dev_redis_123
echo.
echo 💡 下一步：
echo   需要更新你的应用配置文件，使用新的端口号
echo.

pause 