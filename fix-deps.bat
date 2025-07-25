@echo off
echo ===== 修复Gin项目依赖问题 =====
echo.

echo 步骤1: 清理模块缓存...
go clean -modcache

echo 步骤2: 重新下载依赖...
go mod download

echo 步骤3: 整理依赖...
go mod tidy

echo 步骤4: 验证编译...
go build main.go
if %ERRORLEVEL% NEQ 0 (
    echo 编译失败，请检查错误信息
    pause
    exit /b 1
)

echo 步骤5: 启动服务器...
echo 服务器将在 http://localhost:8080 启动
echo Swagger文档：http://localhost:8080/swagger/index.html
echo.
echo 按Ctrl+C停止服务器
go run main.go

pause 