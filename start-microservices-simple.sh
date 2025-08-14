#!/bin/bash

# 简化的微服务启动脚本
# 一键启动所有微服务

set -e

echo "🚀 启动微服务架构电商系统..."

# 检查Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安装，请先安装Docker"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose未安装，请先安装Docker Compose"
    exit 1
fi

# 启动所有服务
echo "📦 构建并启动所有微服务..."
docker-compose up --build -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 15

# 检查服务状态
echo "🔍 检查服务状态..."
docker-compose ps

echo ""
echo "✅ 所有服务启动成功！"
echo ""
echo "🌐 服务访问地址："
echo "   API网关: http://localhost:8080"
echo "   认证服务: http://localhost:8081"
echo "   用户服务: http://localhost:8082"
echo "   商品服务: http://localhost:8083"
echo "   订单服务: http://localhost:8084"
echo "   购物车服务: http://localhost:8085"
echo "   支付服务: http://localhost:8086"
echo "   通知服务: http://localhost:8087"
echo ""
echo "📊 查看日志: docker-compose logs -f"
echo "🛑 停止服务: docker-compose down"
echo ""
echo "🎉 微服务系统已就绪！"