#!/bin/bash

# Go Shop 微服务启动脚本
# 支持多种启动模式：开发、测试、生产

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认配置
ENVIRONMENT=${1:-dev}
COMPOSE_FILE="docker-compose.microservices.yml"

# 打印帮助信息
print_help() {
    echo -e "${BLUE}Go Shop 微服务启动脚本${NC}"
    echo ""
    echo "用法: $0 [环境] [选项]"
    echo ""
    echo "环境:"
    echo "  dev     开发环境 (默认)"
    echo "  test    测试环境"
    echo "  prod    生产环境"
    echo ""
    echo "选项:"
    echo "  --help  显示帮助信息"
    echo "  --stop  停止所有服务"
    echo "  --logs  查看服务日志"
    echo "  --build 重新构建镜像"
    echo "  --reset 重置所有数据"
    echo ""
}

# 检查依赖
check_dependencies() {
    echo -e "${BLUE}检查依赖...${NC}"
    
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker 未安装${NC}"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}错误: Docker Compose 未安装${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}所有依赖已安装${NC}"
}

# 启动开发环境
start_dev() {
    echo -e "${BLUE}启动开发环境...${NC}"
    
    # 启动基础设施服务
    echo -e "${YELLOW}启动基础设施服务...${NC}"
    docker-compose -f $COMPOSE_FILE up -d postgres redis elasticsearch rabbitmq prometheus grafana
    
    # 等待数据库启动
    echo -e "${YELLOW}等待数据库启动...${NC}"
    sleep 10
    
    # 启动微服务
    echo -e "${YELLOW}启动微服务...${NC}"
    docker-compose -f $COMPOSE_FILE up -d auth-service user-service order-service product-service cart-service payment-service notification-service search-service
    
    # 启动API网关
    echo -e "${YELLOW}启动API网关...${NC}"
    docker-compose -f $COMPOSE_FILE up -d api-gateway
    
    echo -e "${GREEN}开发环境启动完成！${NC}"
    echo ""
    echo -e "${BLUE}服务访问地址：${NC}"
    echo "  API Gateway: http://localhost:8080"
    echo "  Prometheus: http://localhost:9090"
    echo "  Grafana: http://localhost:3000 (admin/admin)"
    echo "  RabbitMQ: http://localhost:15672 (admin/admin)"
    echo "  Elasticsearch: http://localhost:9200"
    echo ""
}

# 启动测试环境
start_test() {
    echo -e "${BLUE}启动测试环境...${NC}"
    
    # 使用测试配置
    export COMPOSE_FILE="docker-compose.test.yml"
    
    # 启动服务
    docker-compose -f $COMPOSE_FILE up -d --build
    
    echo -e "${GREEN}测试环境启动完成！${NC}"
}

# 启动生产环境
start_prod() {
    echo -e "${BLUE}启动生产环境...${NC}"
    
    # 检查环境变量
    if [ -z "$JWT_SECRET" ] || [ -z "$DB_PASSWORD" ]; then
        echo -e "${RED}错误: 缺少生产环境变量${NC}"
        echo "请设置以下环境变量："
        echo "  JWT_SECRET"
        echo "  DB_PASSWORD"
        echo "  REDIS_PASSWORD"
        exit 1
    fi
    
    # 使用生产配置
    export COMPOSE_FILE="docker-compose.prod.yml"
    
    # 启动服务
    docker-compose -f $COMPOSE_FILE up -d --build
    
    echo -e "${GREEN}生产环境启动完成！${NC}"
}

# 停止所有服务
stop_services() {
    echo -e "${BLUE}停止所有服务...${NC}"
    docker-compose -f $COMPOSE_FILE down
    echo -e "${GREEN}所有服务已停止${NC}"
}

# 查看日志
view_logs() {
    echo -e "${BLUE}查看服务日志...${NC}"
    docker-compose -f $COMPOSE_FILE logs -f
}

# 重新构建镜像
rebuild_images() {
    echo -e "${BLUE}重新构建镜像...${NC}"
    docker-compose -f $COMPOSE_FILE build --no-cache
    echo -e "${GREEN}镜像重新构建完成${NC}"
}

# 重置所有数据
reset_data() {
    echo -e "${YELLOW}警告: 这将删除所有数据！${NC}"
    read -p "确定要继续吗？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}重置所有数据...${NC}"
        docker-compose -f $COMPOSE_FILE down -v
        docker-compose -f $COMPOSE_FILE up -d
        echo -e "${GREEN}数据重置完成${NC}"
    else
        echo "取消操作"
    fi
}

# 健康检查
health_check() {
    echo -e "${BLUE}健康检查...${NC}"
    
    services=(
        "http://localhost:8080/health"
        "http://localhost:8081/health"
        "http://localhost:8082/health"
        "http://localhost:8083/health"
        "http://localhost:8084/health"
        "http://localhost:8085/health"
        "http://localhost:8086/health"
        "http://localhost:8087/health"
        "http://localhost:8088/health"
    )
    
    for service in "${services[@]}"; do
        if curl -s "$service" > /dev/null; then
            echo -e "${GREEN}✓ $service${NC}"
        else
            echo -e "${RED}✗ $service${NC}"
        fi
    done
}

# 主逻辑
case "${1:-dev}" in
    --help)
        print_help
        ;;
    --stop)
        stop_services
        ;;
    --logs)
        view_logs
        ;;
    --build)
        rebuild_images
        ;;
    --reset)
        reset_data
        ;;
    --health)
        health_check
        ;;
    dev)
        check_dependencies
        start_dev
        health_check
        ;;
    test)
        check_dependencies
        start_test
        ;;
    prod)
        check_dependencies
        start_prod
        ;;
    *)
        echo -e "${RED}错误: 未知选项 $1${NC}"
        print_help
        exit 1
        ;;
esac