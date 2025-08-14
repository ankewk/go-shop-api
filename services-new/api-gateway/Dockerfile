FROM golang:1.21-alpine AS builder

WORKDIR /app

# 安装依赖
COPY go.mod go.sum ./
RUN go mod download

# 复制源代码
COPY services-new/api-gateway/ ./

# 构建应用
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o api-gateway .

FROM alpine:latest

RUN apk --no-cache add ca-certificates
WORKDIR /root/

# 从builder阶段复制二进制文件
COPY --from=builder /app/api-gateway .

EXPOSE 8080

CMD ["./api-gateway"]