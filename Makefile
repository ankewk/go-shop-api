# Go项目Makefile

# 变量定义
BINARY_NAME=gin-project
MAIN_PATH=./main.go

# 默认目标
.DEFAULT_GOAL := help

# 帮助信息
help: ## 显示帮助信息
	@echo "可用命令:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# 安装依赖
deps: ## 安装Go模块依赖
	go mod tidy
	go mod download

# 运行项目
run: ## 运行项目
	go run $(MAIN_PATH)

# 构建项目
build: ## 构建可执行文件
	go build -o $(BINARY_NAME) $(MAIN_PATH)

# 构建Linux版本
build-linux: ## 构建Linux版本
	GOOS=linux GOARCH=amd64 go build -o $(BINARY_NAME)-linux $(MAIN_PATH)

# 构建Windows版本
build-windows: ## 构建Windows版本
	GOOS=windows GOARCH=amd64 go build -o $(BINARY_NAME)-windows.exe $(MAIN_PATH)

# 清理构建文件
clean: ## 清理构建文件
	rm -f $(BINARY_NAME)
	rm -f $(BINARY_NAME)-linux
	rm -f $(BINARY_NAME)-windows.exe

# 格式化代码
fmt: ## 格式化Go代码
	go fmt ./...

# 代码检查
vet: ## 运行go vet检查
	go vet ./...

# 运行测试
test: ## 运行测试
	go test -v ./...

# 代码覆盖率
coverage: ## 生成代码覆盖率报告
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

# 初始化数据库
init-db: ## 运行数据库初始化脚本
	@echo "请手动执行以下SQL脚本初始化数据库:"
	@echo "mysql -u root -p < scripts/init.sql"

# 生成Swagger文档
swag: ## 生成Swagger文档
	@echo "生成Swagger文档..."
	swag init

# 查看Swagger文档
swagger: ## 打开Swagger文档页面
	@echo "Swagger文档地址:"
	@echo "http://localhost:8080/swagger/index.html"

# 开发环境启动
dev: deps fmt vet run ## 开发环境：安装依赖、格式化、检查、运行

# 生产构建
prod: deps fmt vet test build ## 生产构建：完整检查和构建

.PHONY: help deps run build build-linux build-windows clean fmt vet test coverage init-db dev prod 