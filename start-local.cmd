@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   🏠 Go Shop 本地启动器
echo =====================================
echo.

:MAIN_MENU
echo 📋 请选择启动模式：
echo.
echo   【 数据库模式 】
echo   1. 🗄️  本地MySQL启动 (需要安装MySQL)
echo   2. 🐳  Docker MySQL启动 (自动启动容器)
echo   3. 📊  内存数据库启动 (H2/SQLite，仅测试)
echo.
echo   【 启动配置 】
echo   4. 🔧  开发模式启动 (Debug + 热重载)
echo   5. 🚀  生产模式启动 (Release + 优化)
echo   6. 🧪  测试模式启动 (Test + 覆盖率)
echo.
echo   【 快速启动 】
echo   7. ⚡  一键本地启动 (推荐)
echo   8. 🔄  热重载启动 (开发推荐)
echo.
echo   【 工具 】
echo   9. 📖  查看启动帮助
echo   0. ❌  退出
echo.
set /p choice=请输入选项 (0-9): 

if "%choice%"=="1" goto LOCAL_MYSQL
if "%choice%"=="2" goto DOCKER_MYSQL
if "%choice%"=="3" goto MEMORY_DB
if "%choice%"=="4" goto DEV_MODE
if "%choice%"=="5" goto PROD_MODE
if "%choice%"=="6" goto TEST_MODE
if "%choice%"=="7" goto QUICK_START
if "%choice%"=="8" goto HOT_RELOAD
if "%choice%"=="9" goto SHOW_HELP
if "%choice%"=="0" goto EXIT

echo 无效选项，请重新选择...
timeout /t 2
goto MAIN_MENU

:LOCAL_MYSQL
echo.
echo 🗄️  本地MySQL启动模式
echo =====================================
echo.
echo 💡 此模式需要本地安装MySQL服务
echo.
echo 🔧 默认配置：
echo   地址: localhost:3306
echo   用户: root
echo   密码: root
echo   数据库: gin_dev
echo.
set /p confirm=是否使用默认配置？(y/n): 
if /i "%confirm%"=="y" (
    set DB_HOST=localhost
    set DB_PORT=3306
    set DB_USER=root
    set DB_PASSWORD=root
    set DB_NAME=gin_dev
) else (
    set /p DB_HOST=请输入数据库地址 (默认: localhost): 
    if "%DB_HOST%"=="" set DB_HOST=localhost
    
    set /p DB_PORT=请输入数据库端口 (默认: 3306): 
    if "%DB_PORT%"=="" set DB_PORT=3306
    
    set /p DB_USER=请输入数据库用户 (默认: root): 
    if "%DB_USER%"=="" set DB_USER=root
    
    set /p DB_PASSWORD=请输入数据库密码: 
    if "%DB_PASSWORD%"=="" set DB_PASSWORD=root
    
    set /p DB_NAME=请输入数据库名称 (默认: gin_dev): 
    if "%DB_NAME%"=="" set DB_NAME=gin_dev
)

echo.
echo 🔍 检查MySQL连接...
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASSWORD% -e "SELECT 1;" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ MySQL连接失败，请检查：
    echo   1. MySQL服务是否启动
    echo   2. 连接信息是否正确
    echo   3. 用户权限是否足够
    echo.
    pause
    goto MAIN_MENU
)

echo ✅ MySQL连接成功
goto START_APP

:DOCKER_MYSQL
echo.
echo 🐳 Docker MySQL启动模式
echo =====================================
echo.
echo 💡 此模式将自动启动MySQL容器
echo.

:: 检查Docker是否运行
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker未运行，请先启动Docker Desktop
    pause
    goto MAIN_MENU
)

echo 🔍 检查现有MySQL容器...
docker ps | findstr "mysql-local" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ MySQL容器已运行
) else (
    echo 🚀 启动MySQL容器...
    docker run -d --name mysql-local -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=gin_dev mysql:8.0
    if %errorlevel% neq 0 (
        echo ❌ MySQL容器启动失败
        echo 尝试清理旧容器...
        docker rm -f mysql-local >nul 2>&1
        docker run -d --name mysql-local -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=gin_dev mysql:8.0
    )
    echo ⏳ 等待MySQL初始化...
    timeout /t 30
)

set DB_HOST=localhost
set DB_PORT=3306
set DB_USER=root
set DB_PASSWORD=root
set DB_NAME=gin_dev

echo ✅ MySQL容器启动成功
goto START_APP

:MEMORY_DB
echo.
echo 📊 内存数据库启动模式
echo =====================================
echo.
echo 💡 此模式使用内存数据库，数据不会持久化
echo   适用于快速测试和开发
echo.
echo ⚠️  注意：此模式需要修改代码以支持SQLite
echo   当前版本暂不支持，请选择其他模式
echo.
pause
goto MAIN_MENU

:DEV_MODE
echo.
echo 🔧 开发模式启动
echo =====================================
echo.
set GIN_MODE=debug
set LOG_LEVEL=debug
echo ✅ 已设置开发模式配置
echo   - GIN_MODE=debug
echo   - LOG_LEVEL=debug
echo   - 热重载已启用
echo.
goto START_APP

:PROD_MODE
echo.
echo 🚀 生产模式启动
echo =====================================
echo.
set GIN_MODE=release
set LOG_LEVEL=warn
echo ✅ 已设置生产模式配置
echo   - GIN_MODE=release
echo   - LOG_LEVEL=warn
echo   - 性能优化已启用
echo.
goto START_APP

:TEST_MODE
echo.
echo 🧪 测试模式启动
echo =====================================
echo.
echo 🚀 运行测试套件...
go test ./... -v -cover
if %errorlevel% neq 0 (
    echo ❌ 测试失败
    pause
    goto MAIN_MENU
)
echo ✅ 测试通过
echo.
echo 🚀 启动测试服务器...
set GIN_MODE=test
set LOG_LEVEL=debug
goto START_APP

:QUICK_START
echo.
echo ⚡ 一键本地启动
echo =====================================
echo.
echo 🚀 自动配置并启动应用...
echo.

:: 自动检测并启动MySQL
echo 🔍 检测MySQL服务...
netstat -ano | findstr ":3306" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 检测到MySQL服务运行在3306端口
    set DB_HOST=localhost
    set DB_PORT=3306
    set DB_USER=root
    set DB_PASSWORD=root
    set DB_NAME=gin_dev
) else (
    echo 🐳 未检测到MySQL，启动Docker MySQL...
    docker run -d --name mysql-local -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=gin_dev mysql:8.0
    timeout /t 30
    set DB_HOST=localhost
    set DB_PORT=3306
    set DB_USER=root
    set DB_PASSWORD=root
    set DB_NAME=gin_dev
)

set GIN_MODE=debug
set LOG_LEVEL=debug

echo ✅ 配置完成：
echo   - 数据库: %DB_HOST%:%DB_PORT%/%DB_NAME%
echo   - 模式: %GIN_MODE%
echo   - 日志: %LOG_LEVEL%
echo.
goto START_APP

:HOT_RELOAD
echo.
echo 🔄 热重载启动模式
echo =====================================
echo.
echo 💡 此模式需要安装air工具
echo   安装命令: go install github.com/cosmtrek/air@latest
echo.

:: 检查air是否安装
air -v >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ air工具未安装
    echo.
    echo 🔧 正在安装air...
    go install github.com/cosmtrek/air@latest
    if %errorlevel% neq 0 (
        echo ❌ air安装失败
        echo 请手动安装: go install github.com/cosmtrek/air@latest
        pause
        goto MAIN_MENU
    )
)

echo ✅ air工具已安装
echo.
echo 🔄 启动热重载模式...
echo 💡 文件修改后将自动重启服务
echo.

set GIN_MODE=debug
set LOG_LEVEL=debug
set DB_HOST=localhost
set DB_PORT=3306
set DB_USER=root
set DB_PASSWORD=root
set DB_NAME=gin_dev

:: 创建air配置文件
if not exist ".air.toml" (
    echo 创建air配置文件...
    echo # Air配置文件 > .air.toml
    echo root = "." >> .air.toml
    echo testdata_dir = "testdata" >> .air.toml
    echo tmp_dir = "tmp" >> .air.toml
    echo >> .air.toml
    echo [build] >> .air.toml
    echo   args_bin = [] >> .air.toml
    echo   bin = "./tmp/main" >> .air.toml
    echo   cmd = "go build -o ./tmp/main ." >> .air.toml
    echo   delay = 1000 >> .air.toml
    echo   exclude_dir = ["assets", "tmp", "vendor", "testdata"] >> .air.toml
    echo   exclude_file = [] >> .air.toml
    echo   exclude_regex = ["_test.go"] >> .air.toml
    echo   exclude_unchanged = false >> .air.toml
    echo   follow_symlink = false >> .air.toml
    echo   full_bin = "" >> .air.toml
    echo   include_dir = [] >> .air.toml
    echo   include_ext = ["go", "tpl", "tmpl", "html"] >> .air.toml
    echo   include_file = [] >> .air.toml
    echo   kill_delay = "0s" >> .air.toml
    echo   log = "build-errors.log" >> .air.toml
    echo   poll = false >> .air.toml
    echo   poll_interval = 0 >> .air.toml
    echo   rerun = false >> .air.toml
    echo   rerun_delay = 500 >> .air.toml
    echo   send_interrupt = false >> .air.toml
    echo   stop_on_root = false >> .air.toml
    echo >> .air.toml
    echo [color] >> .air.toml
    echo   app = "" >> .air.toml
    echo   build = "yellow" >> .air.toml
    echo   main = "magenta" >> .air.toml
    echo   runner = "green" >> .air.toml
    echo   watcher = "cyan" >> .air.toml
    echo >> .air.toml
    echo [log] >> .air.toml
    echo   main_only = false >> .air.toml
    echo   time = false >> .air.toml
    echo >> .air.toml
    echo [misc] >> .air.toml
    echo   clean_on_exit = false >> .air.toml
)

echo 🚀 启动热重载服务...
air

goto MAIN_MENU

:START_APP
echo.
echo 🚀 启动Go Shop应用...
echo.
echo 📋 启动配置：
echo   - 数据库: %DB_HOST%:%DB_PORT%/%DB_NAME%
echo   - 用户: %DB_USER%
echo   - 模式: %GIN_MODE%
echo   - 日志: %LOG_LEVEL%
echo.

:: 检查Go环境
go version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Go环境未安装或未配置
    echo 请先安装Go 1.21+
    pause
    goto MAIN_MENU
)

:: 下载依赖
echo 📦 下载Go依赖...
go mod tidy
if %errorlevel% neq 0 (
    echo ❌ 依赖下载失败
    pause
    goto MAIN_MENU
)

:: 启动应用
echo 🚀 启动应用服务器...
echo 💡 服务将在 http://localhost:8080 启动
echo 💡 Swagger文档: http://localhost:8080/swagger/index.html
echo.

:: 设置环境变量并启动
set PORT=8080
go run main.go

goto MAIN_MENU

:SHOW_HELP
cls
echo =====================================
echo   📖 本地启动帮助文档
echo =====================================
echo.
echo 🏗️ 系统要求：
echo   - Go 1.21+ 开发环境
echo   - MySQL 8.0+ 数据库 (可选Docker)
echo   - 8GB+ 内存 (推荐16GB)
echo.
echo 🗄️ 数据库选项：
echo   ├─ 本地MySQL: 需要安装MySQL服务
echo   ├─ Docker MySQL: 自动启动容器
echo   └─ 内存数据库: 仅用于测试
echo.
echo 🚀 启动模式：
echo   ├─ 开发模式: Debug + 详细日志
echo   ├─ 生产模式: Release + 性能优化
echo   ├─ 测试模式: 运行测试套件
echo   └─ 热重载: 文件修改自动重启
echo.
echo 🔧 环境变量：
echo   ├─ DB_HOST: 数据库地址
echo   ├─ DB_PORT: 数据库端口
echo   ├─ DB_USER: 数据库用户
echo   ├─ DB_PASSWORD: 数据库密码
echo   ├─ DB_NAME: 数据库名称
echo   ├─ GIN_MODE: Gin运行模式
echo   └─ LOG_LEVEL: 日志级别
echo.
echo 📖 API文档：
echo   ├─ Swagger UI: http://localhost:8080/swagger/index.html
echo   ├─ 健康检查: http://localhost:8080/health
echo   └─ 用户API: http://localhost:8080/api/users
echo.
echo 🛠️ 常用命令：
echo   ├─ 启动服务: go run main.go
echo   ├─ 热重载: air
echo   ├─ 运行测试: go test ./...
echo   ├─ 构建: go build -o app.exe .
echo   └─ 清理: go clean
echo.
pause
goto MAIN_MENU

:EXIT
echo.
echo 👋 感谢使用 Go Shop 本地启动器！
echo.
pause
exit 