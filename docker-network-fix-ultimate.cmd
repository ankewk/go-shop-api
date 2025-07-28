@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
echo =====================================
echo   🔧 Docker 网络终极修复工具
echo =====================================
echo.

echo 🔍 开始全面诊断...
echo.

:: 第一步：检查Docker Desktop状态
echo 📋 第一步：检查Docker Desktop状态
echo ----------------------------------------
tasklist /FI "IMAGENAME eq Docker Desktop.exe" 2>nul | find /I "Docker Desktop.exe" >nul
if %errorlevel% equ 0 (
    echo ✅ Docker Desktop 进程正在运行
) else (
    echo ❌ Docker Desktop 进程未运行
    echo.
    echo 💡 解决方案：
    echo   1. 启动 Docker Desktop 应用程序
    echo   2. 等待 Docker 完全启动（托盘图标变绿色）
    echo   3. 重新运行此脚本
    echo.
    echo 🚀 正在尝试启动Docker Desktop...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe" 2>nul
    if %errorlevel% neq 0 (
        echo ❌ 无法自动启动Docker Desktop，请手动启动
    ) else (
        echo ✅ 已尝试启动Docker Desktop，请等待30秒...
        timeout /t 30
    )
)

echo.

:: 第二步：检查Docker命令可用性
echo 📋 第二步：检查Docker命令
echo ----------------------------------------
docker --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Docker 命令可用
    docker --version
) else (
    echo ❌ Docker 命令不可用
    echo.
    echo 💡 可能的原因：
    echo   - Docker Desktop 未完全启动
    echo   - Docker 未正确安装
    echo   - 环境变量配置问题
    echo.
    echo 🔄 等待Docker启动完成...
    timeout /t 60
    
    docker --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo ❌ Docker 仍然不可用，请检查安装
        echo.
        echo 📝 手动解决步骤：
        echo   1. 确保 Docker Desktop 已安装
        echo   2. 重启 Docker Desktop
        echo   3. 重启计算机
        echo   4. 检查 Windows 功能中的虚拟化设置
        pause
        exit /b 1
    )
)

echo.

:: 第三步：清理旧容器和网络
echo 📋 第三步：清理资源
echo ----------------------------------------
echo 🧹 停止相关容器...
docker stop gin-mysql-dev gin-redis-dev gin-api-gateway-dev gin-nginx-dev gin-prometheus-dev gin-grafana-dev >nul 2>&1

echo 🗑️ 删除旧容器...
docker rm gin-mysql-dev gin-redis-dev gin-api-gateway-dev gin-nginx-dev gin-prometheus-dev gin-grafana-dev >nul 2>&1

echo 🌐 清理网络...
docker network rm go-shop-dev-network >nul 2>&1
docker network prune -f >nul 2>&1

echo 💾 清理卷...
docker volume prune -f >nul 2>&1

echo ✅ 资源清理完成
echo.

:: 第四步：检查端口占用
echo 📋 第四步：检查端口占用
echo ----------------------------------------
echo 检查关键端口状态：

for %%p in (3307 8080 6379 9090 3000) do (
    netstat -ano | findstr ":%%p " >nul 2>&1
    if !errorlevel! equ 0 (
        echo   ❌ 端口 %%p 被占用
        for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%%p "') do (
            echo      进程ID: %%a
        )
    ) else (
        echo   ✅ 端口 %%p 空闲
    )
)

echo.

:: 第五步：检查Windows功能
echo 📋 第五步：检查Windows虚拟化功能
echo ----------------------------------------
dism /online /get-featureinfo /featurename:Microsoft-Hyper-V-All >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Hyper-V 功能可用
) else (
    echo ❌ Hyper-V 功能未启用
    echo 💡 请确保启用了 Windows 的虚拟化功能
)

echo.

:: 第六步：测试网络连接
echo 📋 第六步：测试Docker网络
echo ----------------------------------------
echo 🌐 创建测试网络...
docker network create test-network >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Docker 网络创建成功
    docker network rm test-network >nul 2>&1
) else (
    echo ❌ Docker 网络创建失败
    echo.
    echo 💡 这可能是网络驱动问题，尝试重置Docker网络：
    echo 🔄 重置Docker网络设置...
    docker system prune -a -f >nul 2>&1
)

echo.

:: 第七步：尝试替代端口启动
echo 📋 第七步：使用替代端口启动
echo ----------------------------------------
echo 🚀 尝试使用替代端口启动MySQL...

:: 使用3308端口而不是3307
docker run -d --name gin-mysql-dev-alt -p 3308:3306 -e MYSQL_ROOT_PASSWORD=dev_root_123 -e MYSQL_DATABASE=gin_dev -e MYSQL_USER=gin_dev_user -e MYSQL_PASSWORD=gin_dev_pass mysql:8.0 >nul 2>&1

if %errorlevel% equ 0 (
    echo ✅ MySQL 在替代端口 3308 启动成功！
    echo.
    echo 📊 检查容器状态：
    docker ps --filter name=gin-mysql-dev-alt
    echo.
    echo 🔧 数据库连接信息（更新）：
    echo   地址: localhost:3308
    echo   数据库: gin_dev  
    echo   用户: gin_dev_user
    echo   密码: gin_dev_pass
    echo.
    echo 💡 注意：需要更新应用配置使用端口 3308
) else (
    echo ❌ 替代端口启动也失败
    echo.
    echo 🔧 终极解决方案：
    echo   1. 重启 Docker Desktop
    echo   2. 重启计算机
    echo   3. 重新安装 Docker Desktop
    echo   4. 检查杀毒软件是否阻止
    echo   5. 使用 WSL2 后端而不是 Hyper-V
)

echo.

:: 第八步：提供诊断报告
echo 📋 第八步：生成诊断报告
echo ----------------------------------------
echo 📄 诊断报告已保存到 docker-diagnosis.txt

echo 🔧 Docker 网络诊断报告 > docker-diagnosis.txt
echo 生成时间: %date% %time% >> docker-diagnosis.txt
echo. >> docker-diagnosis.txt

echo === Docker 版本信息 === >> docker-diagnosis.txt
docker --version >> docker-diagnosis.txt 2>&1
echo. >> docker-diagnosis.txt

echo === 容器状态 === >> docker-diagnosis.txt
docker ps -a >> docker-diagnosis.txt 2>&1
echo. >> docker-diagnosis.txt

echo === 网络列表 === >> docker-diagnosis.txt
docker network ls >> docker-diagnosis.txt 2>&1
echo. >> docker-diagnosis.txt

echo === 系统信息 === >> docker-diagnosis.txt
systeminfo | findstr /C:"OS Name" /C:"OS Version" /C:"System Type" >> docker-diagnosis.txt 2>&1

echo.
echo =====================================
echo   🎯 修复建议总结
echo =====================================
echo.
echo 🔍 如果问题仍然存在，请尝试以下操作：
echo.
echo 1️⃣ 重启Docker Desktop：
echo    - 右键点击托盘中的Docker图标
echo    - 选择 "Restart Docker Desktop"
echo.
echo 2️⃣ 切换Docker后端：
echo    - 打开 Docker Desktop 设置
echo    - 切换到 WSL2 或 Hyper-V 后端
echo.
echo 3️⃣ 重置Docker到出厂设置：
echo    - Docker Desktop 设置 → Troubleshoot → Reset to factory defaults
echo.
echo 4️⃣ 使用替代启动方式：
echo    - 运行 start-dev-simple.cmd
echo    - 或使用不同的端口配置
echo.
echo 5️⃣ 检查杀毒软件：
echo    - 确保杀毒软件没有阻止Docker
echo    - 添加Docker到白名单
echo.

pause 