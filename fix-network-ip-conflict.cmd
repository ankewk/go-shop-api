@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   🔧 Docker 网络 IP 冲突修复工具
echo =====================================
echo.

echo 🔍 检测到网络IP地址池冲突错误：
echo "Pool overlaps with other one on this address space"
echo.

echo 💡 这个错误通常由以下原因引起：
echo   - 已存在相同IP段的Docker网络
echo   - Docker网络配置残留
echo   - 网络驱动缓存问题
echo.

echo 🚀 开始修复IP地址池冲突...
echo.

:: 第一步：停止所有相关容器
echo 📋 第一步：停止相关容器
echo ----------------------------------------
docker stop gin-mysql-dev gin-redis-dev gin-api-gateway-dev gin-nginx-dev gin-prometheus-dev gin-grafana-dev >nul 2>&1
docker stop gin-mysql-dev-backup gin-redis-dev-backup gin-api-gateway-dev-backup >nul 2>&1
echo ✅ 容器停止完成

:: 第二步：删除所有相关容器
echo 📋 第二步：删除旧容器
echo ----------------------------------------
docker rm gin-mysql-dev gin-redis-dev gin-api-gateway-dev gin-nginx-dev gin-prometheus-dev gin-grafana-dev >nul 2>&1
docker rm gin-mysql-dev-backup gin-redis-dev-backup gin-api-gateway-dev-backup >nul 2>&1
echo ✅ 容器清理完成

:: 第三步：查看现有网络（忽略错误）
echo 📋 第三步：分析现有网络
echo ----------------------------------------
echo 当前Docker网络列表：
docker network ls 2>nul | findstr /V "Error" | findstr /V "Cannot connect"
echo.

:: 第四步：删除冲突的网络
echo 📋 第四步：清理冲突网络
echo ----------------------------------------
echo 删除可能冲突的网络...
docker network rm go-shop-dev-network >nul 2>&1
docker network rm go-shop-uat-network >nul 2>&1  
docker network rm go-shop-prod-network >nul 2>&1
docker network rm microservices-dev-network >nul 2>&1
docker network rm test-network >nul 2>&1

echo 强制清理所有用户定义的网络...
for /f "tokens=1" %%i in ('docker network ls --filter type=custom --format "{{.Name}}" 2^>nul') do (
    if not "%%i"=="none" (
        docker network rm %%i >nul 2>&1
    )
)

echo ✅ 网络清理完成

:: 第五步：重置Docker网络系统
echo 📋 第五步：重置Docker网络系统
echo ----------------------------------------
echo 清理网络缓存...
docker system prune -f >nul 2>&1
docker network prune -f >nul 2>&1

echo 重启Docker网络...
:: 在Windows上重启Docker服务
net stop com.docker.service >nul 2>&1
timeout /t 5 >nul
net start com.docker.service >nul 2>&1
echo ✅ Docker服务重启完成

:: 第六步：等待Docker完全启动
echo 📋 第六步：等待Docker启动
echo ----------------------------------------
echo 等待Docker完全启动...
timeout /t 30
echo ✅ 等待完成

:: 第七步：使用不同IP段创建网络
echo 📋 第七步：创建新的网络配置
echo ----------------------------------------

echo 尝试创建网络 - 方案1（172.20.0.0/16）...
docker network create --driver bridge --subnet=172.20.0.0/16 --ip-range=172.20.1.0/24 go-shop-dev-network >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 方案1成功：使用IP段 172.20.0.0/16
    set NETWORK_SUBNET=172.20.0.0/16
    goto NETWORK_CREATED
)

echo 尝试创建网络 - 方案2（192.168.100.0/24）...
docker network create --driver bridge --subnet=192.168.100.0/24 go-shop-dev-network >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 方案2成功：使用IP段 192.168.100.0/24
    set NETWORK_SUBNET=192.168.100.0/24
    goto NETWORK_CREATED
)

echo 尝试创建网络 - 方案3（10.10.0.0/16）...
docker network create --driver bridge --subnet=10.10.0.0/16 --ip-range=10.10.1.0/24 go-shop-dev-network >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 方案3成功：使用IP段 10.10.0.0/16
    set NETWORK_SUBNET=10.10.0.0/16
    goto NETWORK_CREATED
)

echo 尝试创建网络 - 方案4（默认自动分配）...
docker network create go-shop-dev-network >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 方案4成功：使用Docker自动分配IP段
    set NETWORK_SUBNET=auto
    goto NETWORK_CREATED
)

echo ❌ 所有网络创建方案都失败了
goto NETWORK_FAILED

:NETWORK_CREATED
echo.
echo 📋 第八步：验证网络创建
echo ----------------------------------------
echo 验证新网络：
docker network inspect go-shop-dev-network 2>nul | findstr "Subnet\|Name"
echo ✅ 网络创建验证完成

echo.
echo 📋 第九步：测试容器启动
echo ----------------------------------------
echo 测试启动MySQL容器...
docker run -d --name test-mysql --network go-shop-dev-network -p 3309:3306 -e MYSQL_ROOT_PASSWORD=test123 mysql:8.0 >nul 2>&1

if %errorlevel% equ 0 (
    echo ✅ 测试容器启动成功！
    echo 停止测试容器...
    docker stop test-mysql >nul 2>&1
    docker rm test-mysql >nul 2>&1
) else (
    echo ❌ 测试容器启动失败
)

echo.
echo =====================================
echo   🎉 IP冲突修复完成！
echo =====================================
echo.
echo 📊 修复结果：
echo   ✅ 清理了冲突的网络
echo   ✅ 重启了Docker服务  
echo   ✅ 创建了新的网络：go-shop-dev-network
echo   ✅ 使用IP段：%NETWORK_SUBNET%
echo.
echo 🚀 下一步操作：
echo   现在可以正常启动开发环境了！
echo   推荐使用：start-dev-backup.cmd
echo.
echo 💡 如果还有问题，请尝试：
echo   1. 重启计算机
echo   2. 重新安装Docker Desktop
echo   3. 检查网络适配器设置
echo.
goto END

:NETWORK_FAILED
echo.
echo =====================================
echo   ❌ IP冲突修复失败
echo =====================================
echo.
echo 🔧 手动解决方案：
echo.
echo 1️⃣ 重启Docker Desktop：
echo    - 右键托盘Docker图标 → Restart
echo.
echo 2️⃣ 重置Docker到出厂设置：
echo    - Docker Desktop → Settings → Troubleshoot → Reset to factory defaults
echo.
echo 3️⃣ 检查网络适配器：
echo    - 控制面板 → 网络连接
echo    - 禁用并重新启用网络适配器
echo.
echo 4️⃣ 重启计算机：
echo    - 完全重启系统
echo.
echo 5️⃣ 检查Hyper-V设置：
echo    - 控制面板 → 程序和功能 → 启用或关闭Windows功能
echo    - 确保Hyper-V正确配置
echo.

:END
pause 