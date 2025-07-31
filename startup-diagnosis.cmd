@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
echo =====================================
echo   🔍 开发环境启动问题诊断工具
echo =====================================
echo.

echo 📋 正在收集系统信息，请稍等...
echo.

:: 创建诊断报告文件
echo 🔧 Go Shop 开发环境启动诊断报告 > startup-diagnosis.txt
echo 生成时间: %date% %time% >> startup-diagnosis.txt
echo ======================================== >> startup-diagnosis.txt
echo. >> startup-diagnosis.txt

:: 1. 检查Docker Desktop状态
echo 📋 第一步：检查Docker Desktop状态
echo ----------------------------------------
echo === Docker Desktop 状态检查 === >> startup-diagnosis.txt

tasklist /FI "IMAGENAME eq Docker Desktop.exe" 2>nul | find /I "Docker Desktop.exe" >nul
if %errorlevel% equ 0 (
    echo ✅ Docker Desktop 进程运行中
    echo [✅] Docker Desktop 进程运行中 >> startup-diagnosis.txt
) else (
    echo ❌ Docker Desktop 进程未运行
    echo [❌] Docker Desktop 进程未运行 >> startup-diagnosis.txt
    echo.
    echo 💡 解决方案：
    echo   1. 启动 Docker Desktop 应用程序
    echo   2. 等待Docker完全启动（托盘图标变绿色）
    echo   3. 重新运行此诊断
)

:: 2. 检查Docker命令
echo.
echo 📋 第二步：检查Docker命令可用性
echo ----------------------------------------
docker --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Docker 命令可用
    echo [✅] Docker 命令可用 >> startup-diagnosis.txt
    docker --version >> startup-diagnosis.txt
) else (
    echo ❌ Docker 命令不可用
    echo [❌] Docker 命令不可用 >> startup-diagnosis.txt
    echo.
    echo 💡 可能的问题：
    echo   - Docker Desktop 未完全启动
    echo   - PATH环境变量问题
    echo   - Docker安装问题
)

:: 3. 检查Go环境
echo.
echo 📋 第三步：检查Go环境
echo ----------------------------------------
echo === Go 环境检查 === >> startup-diagnosis.txt
go version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Go 环境可用
    echo [✅] Go 环境可用 >> startup-diagnosis.txt
    go version >> startup-diagnosis.txt
) else (
    echo ❌ Go 环境不可用
    echo [❌] Go 环境不可用 >> startup-diagnosis.txt
    echo.
    echo 💡 解决方案：
    echo   1. 下载安装 Go 1.21+ 
    echo   2. 配置PATH环境变量
)

:: 4. 检查端口占用
echo.
echo 📋 第四步：检查关键端口占用
echo ----------------------------------------
echo === 端口占用检查 === >> startup-diagnosis.txt

for %%p in (3306 3307 3308 3309 6379 6380 6381 8080 8082 8083 8084 8085) do (
    netstat -ano | findstr ":%%p " >nul 2>&1
    if !errorlevel! equ 0 (
        echo ❌ 端口 %%p 被占用
        echo [❌] 端口 %%p 被占用 >> startup-diagnosis.txt
        for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%%p "') do (
            echo      进程ID: %%a >> startup-diagnosis.txt
        )
    ) else (
        echo ✅ 端口 %%p 空闲
        echo [✅] 端口 %%p 空闲 >> startup-diagnosis.txt
    )
)

:: 5. 检查项目文件
echo.
echo 📋 第五步：检查项目文件结构
echo ----------------------------------------
echo === 项目文件检查 === >> startup-diagnosis.txt

if exist "go.mod" (
    echo ✅ go.mod 存在
    echo [✅] go.mod 存在 >> startup-diagnosis.txt
) else (
    echo ❌ go.mod 不存在
    echo [❌] go.mod 不存在 >> startup-diagnosis.txt
)

if exist "main.go" (
    echo ✅ main.go 存在
    echo [✅] main.go 存在 >> startup-diagnosis.txt
) else (
    echo ❌ main.go 不存在
    echo [❌] main.go 不存在 >> startup-diagnosis.txt
)

if exist "services\" (
    echo ✅ services 目录存在
    echo [✅] services 目录存在 >> startup-diagnosis.txt
    
    for %%s in (user-service product-service cart-service order-service) do (
        if exist "services\%%s\main.go" (
            echo ✅ services\%%s\main.go 存在
            echo [✅] services\%%s\main.go 存在 >> startup-diagnosis.txt
        ) else (
            echo ❌ services\%%s\main.go 不存在
            echo [❌] services\%%s\main.go 不存在 >> startup-diagnosis.txt
        )
    )
) else (
    echo ❌ services 目录不存在
    echo [❌] services 目录不存在 >> startup-diagnosis.txt
)

:: 6. 检查配置文件
echo.
echo 📋 第六步：检查配置文件
echo ----------------------------------------
echo === 配置文件检查 === >> startup-diagnosis.txt

if exist "config\dev.env" (
    echo ✅ config\dev.env 存在
    echo [✅] config\dev.env 存在 >> startup-diagnosis.txt
) else (
    echo ❌ config\dev.env 不存在
    echo [❌] config\dev.env 不存在 >> startup-diagnosis.txt
)

if exist "config\dev-backup.env" (
    echo ✅ config\dev-backup.env 存在
    echo [✅] config\dev-backup.env 存在 >> startup-diagnosis.txt
) else (
    echo ❌ config\dev-backup.env 不存在
    echo [❌] config\dev-backup.env 不存在 >> startup-diagnosis.txt
)

:: 7. 检查Docker容器
echo.
echo 📋 第七步：检查Docker容器状态
echo ----------------------------------------
echo === Docker 容器状态 === >> startup-diagnosis.txt
docker ps -a 2>nul >> startup-diagnosis.txt
if %errorlevel% equ 0 (
    echo ✅ 成功获取容器信息
    echo [✅] 成功获取容器信息 >> startup-diagnosis.txt
) else (
    echo ❌ 无法获取容器信息
    echo [❌] 无法获取容器信息 >> startup-diagnosis.txt
)

:: 8. 生成建议
echo.
echo 📋 第八步：生成解决建议
echo ----------------------------------------

echo === 解决建议 === >> startup-diagnosis.txt

:: 基于检查结果给出建议
tasklist /FI "IMAGENAME eq Docker Desktop.exe" 2>nul | find /I "Docker Desktop.exe" >nul
if %errorlevel% neq 0 (
    echo 🔧 建议1：启动Docker Desktop >> startup-diagnosis.txt
    echo   - 双击桌面上的Docker Desktop图标 >> startup-diagnosis.txt
    echo   - 等待托盘图标变为绿色 >> startup-diagnosis.txt
    echo. >> startup-diagnosis.txt
)

go version >nul 2>&1
if %errorlevel% neq 0 (
    echo 🔧 建议2：安装Go环境 >> startup-diagnosis.txt
    echo   - 下载：https://golang.org/dl/ >> startup-diagnosis.txt
    echo   - 安装Go 1.21或更高版本 >> startup-diagnosis.txt
    echo. >> startup-diagnosis.txt
)

if not exist "go.mod" (
    echo 🔧 建议3：检查项目目录 >> startup-diagnosis.txt
    echo   - 确保在正确的项目根目录 >> startup-diagnosis.txt
    echo   - 当前目录应该包含go.mod文件 >> startup-diagnosis.txt
    echo. >> startup-diagnosis.txt
)

echo.
echo =====================================
echo   📊 诊断完成！
echo =====================================
echo.
echo 📄 详细诊断报告已保存到: startup-diagnosis.txt
echo.
echo 🔍 根据诊断结果，常见解决方案：
echo.
echo 1️⃣ 如果Docker Desktop未运行：
echo    → 启动Docker Desktop，等待完全启动
echo.
echo 2️⃣ 如果Go环境有问题：
echo    → 安装Go 1.21+，配置环境变量
echo.
echo 3️⃣ 如果端口被占用：
echo    → 运行 fix-network-ip-conflict.cmd
echo.
echo 4️⃣ 如果配置文件有问题：
echo    → 检查config目录下的.env文件
echo.
echo 5️⃣ 如果Docker命令不可用：
echo    → 重启Docker Desktop或重启计算机
echo.

echo 💡 下一步建议：
echo   1. 查看 startup-diagnosis.txt 文件了解详细信息
echo   2. 根据问题类型选择对应的解决方案
echo   3. 解决问题后重新尝试启动
echo.

pause 