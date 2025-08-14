#!/bin/bash

# 一键启动微服务架构的简化脚本
# 适用于快速开发和测试

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 开始启动微服务架构...${NC}"

# 检查Docker环境
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安装，请先安装Docker"
    exit 1
fi

# 启动所有服务
echo -e "${YELLOW}⏳ 正在启动所有服务...${NC}"
docker-compose -f docker-compose.microservices.yml up -d

# 等待服务启动
echo -e "${YELLOW}⏳ 等待服务启动完成...${NC}"
sleep 15

# 检查服务状态
echo -e "${BLUE}📊 服务状态检查:${NC}"
docker-compose -f docker-compose.microservices.yml ps --format "table {{.Service}}\t{{.Status}}\t{{.Ports}}"

# 初始化数据库
echo -e "${YELLOW}⏳ 初始化数据库...${NC}"
chmod +x init-microservices-db.sh
./init-microservices-db.sh

# 部署订单分表
echo -e "${YELLOW}⏳ 部署订单分表...${NC}"
chmod +x setup-sharding.sh
./setup-sharding.sh

echo ""
echo -e "${GREEN}✅ 微服务架构启动完成！${NC}"
echo ""
echo -e "${BLUE}🌐 访问地址:${NC}"
echo "  前端应用: http://localhost:3000"
echo "  API网关:  http://localhost:8080"
echo "  监控面板: http://localhost:9090 (Prometheus)"
echo "  消息队列: http://localhost:15672 (RabbitMQ: guest/guest)"
echo ""
echo -e "${BLUE}📚 使用命令:${NC}"
echo "  查看日志: docker-compose -f docker-compose.microservices.yml logs -f"
echo "  停止服务: docker-compose -f docker-compose.microservices.yml down"
echo "  重启服务: ./start-all-microservices.sh --restart"
echo ""
echo -e "${GREEN}🎉 所有服务已就绪，可以开始使用了！${NC}"