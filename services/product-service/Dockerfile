# 多阶段构建 - 产品服务

# 第一阶段：构建阶段
FROM golang:1.21-alpine AS builder

# 设置工作目录
WORKDIR /app

# 安装必要的工具
RUN apk add --no-cache git

# 复制共享包
COPY shared/ ./shared/

# 复制服务源代码和依赖
COPY services/product-service/ ./

# 下载依赖（使用共享包）
RUN go mod init gin-project/services/product-service && \
    go mod edit -require gin-project/shared@v0.0.0 && \
    go mod edit -replace gin-project/shared=./shared && \
    go mod tidy

# 构建应用
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# 第二阶段：运行阶段
FROM alpine:latest

# 安装必要的包
RUN apk --no-cache add ca-certificates tzdata wget

# 设置时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 创建运行用户
RUN addgroup -g 1001 appgroup && \
    adduser -D -s /bin/sh -u 1001 -G appgroup appuser

# 设置工作目录
WORKDIR /app

# 从构建阶段复制二进制文件
COPY --from=builder /app/main .

# 设置文件权限
RUN chmod +x ./main

# 切换到非root用户
USER appuser

# 暴露端口
EXPOSE 8082

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8082/health || exit 1

# 启动应用
CMD ["./main"] 