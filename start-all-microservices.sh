#!/bin/bash

# 启动所有微服务的Docker脚本
# 一键启动完整的微服务架构

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的信息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    echo "启动所有微服务的Docker脚本"
    echo ""
    echo "使用方法:"
    echo "  ./start-all-microservices.sh [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help     显示帮助信息"
    echo "  -d, --dev      使用开发环境配置"
    echo "  -p, --prod     使用生产环境配置"
    echo "  -r, --restart  重启服务"
    echo "  -s, --stop     停止所有服务"
    echo "  -l, --logs     查看日志"
    echo "  --build        重新构建镜像"
    echo "  --init-db      初始化数据库"
    echo "  --sharding     部署订单分表"
    echo ""
    echo "示例:"
    echo "  ./start-all-microservices.sh --dev --init-db"
    echo "  ./start-all-microservices.sh --restart --sharding"
}

# 检查Docker和Docker Compose
check_docker() {
    print_info "检查Docker环境..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker未安装，请先安装Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose未安装，请先安装Docker Compose"
        exit 1
    fi
    
    print_success "Docker环境检查通过"
}

# 检查端口占用
check_ports() {
    print_info "检查端口占用情况..."
    
    local ports=("3000" "8080" "8081" "8082" "8083" "8084" "8085" "8086" "8087" "9200" "5672" "15672" "9090")
    local occupied_ports=()
    
    for port in "${ports[@]}"; do
        if lsof -i :"$port" &> /dev/null; then
            occupied_ports+=("$port")
        fi
    done
    
    if [ ${#occupied_ports[@]} -gt 0 ]; then
        print_warning "以下端口已被占用: ${occupied_ports[*]}"
        print_warning "这些端口将被Docker容器使用"
    else
        print_success "所有端口可用"
    fi
}

# 启动服务
start_services() {
    local build_flag=""
    local env_file="docker-compose.microservices.yml"
    
    if [[ "$1" == "--build" ]]; then
        build_flag="--build"
        print_info "将重新构建Docker镜像..."
    fi
    
    print_info "启动所有微服务..."
    print_info "使用配置文件: $env_file"
    
    # 启动所有服务
    docker-compose -f "$env_file" up -d $build_flag
    
    # 等待服务启动
    print_info "等待服务启动..."
    sleep 10
    
    # 检查服务状态
    check_service_status
}

# 检查服务状态
check_service_status() {
    print_info "检查服务状态..."
    
    local services=(
        "postgres-auth"
        "postgres-user"
        "postgres-product"
        "postgres-order"
        "postgres-cart"
        "postgres-payment"
        "postgres-notification"
        "redis-auth"
        "redis-user"
        "redis-product"
        "redis-cart"
        "redis-payment"
        "api-gateway"
        "auth-service"
        "user-service"
        "product-service"
        "order-service"
        "cart-service"
        "payment-service"
        "notification-service"
        "search-service"
        "rabbitmq"
        "elasticsearch"
        "prometheus"
    )
    
    local running_count=0
    local total_count=${#services[@]}
    
    for service in "${services[@]}"; do
        if docker-compose -f docker-compose.microservices.yml ps | grep -q "$service.*Up"; then
            print_success "$service: 运行中"
            ((running_count++))
        else
            print_warning "$service: 未运行"
        fi
    done
    
    echo ""
    print_info "服务状态: $running_count/$total_count 个服务正在运行"
    
    if [ $running_count -eq $total_count ]; then
        print_success "所有服务启动成功！"
    else
        print_warning "部分服务未启动，请检查日志"
    fi
}

# 停止所有服务
stop_services() {
    print_info "停止所有微服务..."
    
    docker-compose -f docker-compose.microservices.yml down
    
    # 清理网络
    docker network prune -f
    
    print_success "所有服务已停止"
}

# 查看日志
show_logs() {
    print_info "查看服务日志..."
    
    # 显示最近100行日志
    docker-compose -f docker-compose.microservices.yml logs --tail=100 -f
}

# 初始化数据库
init_databases() {
    print_info "初始化所有微服务数据库..."
    
    # 等待数据库服务完全启动
    sleep 5
    
    # 执行数据库初始化脚本
    if [ -f "./init-microservices-db.sh" ]; then
        chmod +x ./init-microservices-db.sh
        ./init-microservices-db.sh
        print_success "数据库初始化完成"
    else
        print_error "数据库初始化脚本未找到"
        exit 1
    fi
}

# 部署订单分表
deploy_sharding() {
    print_info "部署订单分表功能..."
    
    if [ -f "./setup-sharding.sh" ]; then
        chmod +x ./setup-sharding.sh
        ./setup-sharding.sh
        print_success "订单分表部署完成"
    else
        print_error "分表部署脚本未找到"
        exit 1
    fi
}

# 显示服务访问信息
show_access_info() {
    print_info "服务访问信息:"
    echo ""
    echo "🌐 前端应用:"
    echo "   http://localhost:3000"
    echo ""
    echo "🚪 API网关:"
    echo "   http://localhost:8080"
    echo ""
    echo "🔐 认证服务:"
    echo "   http://localhost:8081"
    echo ""
    echo "👤 用户服务:"
    echo "   http://localhost:8082"
    echo ""
    echo "📦 商品服务:"
    echo "   http://localhost:8083"
    echo ""
    echo "📋 订单服务:"
    echo "   http://localhost:8084"
    echo ""
    echo "🛒 购物车服务:"
    echo "   http://localhost:8085"
    echo ""
    echo "💳 支付服务:"
    echo "   http://localhost:8086"
    echo ""
    echo "🔔 通知服务:"
    echo "   http://localhost:8087"
    echo ""
    echo "🔍 搜索服务:"
    echo "   http://localhost:8088"
    echo ""
    echo "📊 监控工具:"
    echo "   Prometheus: http://localhost:9090"
    echo "   RabbitMQ:   http://localhost:15672 (guest/guest)"
    echo "   Elasticsearch: http://localhost:9200"
    echo ""
    echo "🗄️ 数据库:"
    echo "   PostgreSQL: localhost:5432 (各服务独立数据库)"
    echo "   Redis:      localhost:6379 (各服务独立实例)"
}

# 主函数
main() {
    # 默认参数
    local action="start"
    local build_flag=""
    local init_db=false
    local deploy_sharding_flag=false
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--dev)
                print_info "使用开发环境配置"
                ;;
            -p|--prod)
                print_info "使用生产环境配置"
                ;;
            -r|--restart)
                action="restart"
                ;;
            -s|--stop)
                action="stop"
                ;;
            -l|--logs)
                action="logs"
                ;;
            --build)
                build_flag="--build"
                ;;
            --init-db)
                init_db=true
                ;;
            --sharding)
                deploy_sharding_flag=true
                ;;
            *)
                print_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done
    
    # 执行操作
    case $action in
        start)
            check_docker
            check_ports
            start_services $build_flag
            
            if [[ "$init_db" == true ]]; then
                init_databases
            fi
            
            if [[ "$deploy_sharding_flag" == true ]]; then
                deploy_sharding
            fi
            
            show_access_info
            ;;
        restart)
            stop_services
            sleep 3
            check_docker
            check_ports
            start_services $build_flag
            
            if [[ "$init_db" == true ]]; then
                init_databases
            fi
            
            if [[ "$deploy_sharding_flag" == true ]]; then
                deploy_sharding
            fi
            
            show_access_info
            ;;
        stop)
            stop_services
            ;;
        logs)
            show_logs
            ;;
    esac
}

# 如果直接运行脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi