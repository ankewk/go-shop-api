@echo off
echo 正在下载依赖...
go mod tidy
go mod download

echo 正在启动服务器...
go run main.go

pause 