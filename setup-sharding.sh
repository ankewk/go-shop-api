#!/bin/bash

# 订单分表部署脚本
# 一键部署订单分表功能

set -e

echo "🚀 开始部署订单分表功能..."

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查PostgreSQL连接
echo "🔍 检查PostgreSQL连接..."
if ! docker exec postgres-order pg_isready -U order_user -d order_db > /dev/null 2>&1; then
    echo -e "${RED}❌ PostgreSQL连接失败，请先启动微服务架构${NC}"
    echo "运行: docker-compose -f docker-compose.microservices.yml up -d"
    exit 1
fi

# 等待PostgreSQL完全启动
echo "⏳ 等待PostgreSQL完全启动..."
sleep 5

# 初始化分表
echo "📊 初始化订单分表..."
docker exec postgres-order psql -U order_user -d order_db -f /app/services/order-service/scripts/init_sharding_tables.sql

# 检查分表是否创建成功
echo "✅ 验证分表创建..."
table_count=$(docker exec postgres-order psql -U order_user -d order_db -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name LIKE 'orders_%' AND table_name != 'orders';" | tr -d ' ')

if [ "$table_count" -eq 10 ]; then
    echo -e "${GREEN}✅ 成功创建10个订单分表${NC}"
else
    echo -e "${RED}❌ 分表创建失败，期望10个，实际$((table_count))个${NC}"
    exit 1
fi

# 显示分表统计
echo "📈 分表统计信息:"
docker exec postgres-order psql -U order_user -d order_db -c "
SELECT 
    'orders_' || LPAD(generate_series::TEXT, 2, '0') as table_name,
    (SELECT COUNT(*) FROM orders_00 WHERE generate_series = 0) as record_count
FROM generate_series(0,9)
UNION ALL
SELECT 'orders_01', (SELECT COUNT(*) FROM orders_01) WHERE 1=1
UNION ALL
SELECT 'orders_02', (SELECT COUNT(*) FROM orders_02) WHERE 1=1
UNION ALL
SELECT 'orders_03', (SELECT COUNT(*) FROM orders_03) WHERE 1=1
UNION ALL
SELECT 'orders_04', (SELECT COUNT(*) FROM orders_04) WHERE 1=1
UNION ALL
SELECT 'orders_05', (SELECT COUNT(*) FROM orders_05) WHERE 1=1
UNION ALL
SELECT 'orders_06', (SELECT COUNT(*) FROM orders_06) WHERE 1=1
UNION ALL
SELECT 'orders_07', (SELECT COUNT(*) FROM orders_07) WHERE 1=1
UNION ALL
SELECT 'orders_08', (SELECT COUNT(*) FROM orders_08) WHERE 1=1
UNION ALL
SELECT 'orders_09', (SELECT COUNT(*) FROM orders_09) WHERE 1=1
ORDER BY table_name;
"

# 运行测试
echo "🧪 运行分表功能测试..."
cd services/order-service
if go test -v ./tests/... > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 分表功能测试通过${NC}"
else
    echo -e "${YELLOW}⚠️  分表功能测试失败，请检查配置${NC}"
fi

echo ""
echo -e "${GREEN}🎉 订单分表部署完成！${NC}"
echo ""
echo "📚 使用说明:"
echo "1. 分表规则: 基于user_id % 10"
echo "2. 表名格式: orders_00 到 orders_09"
echo "3. 测试用户:"
echo "   - UserID 10 -> orders_00"
echo "   - UserID 11 -> orders_01"
echo "   - UserID 123 -> orders_03"
echo ""
echo "🔧 管理命令:"
echo "   # 初始化分表"
echo "   go run services/order-service/cmd/sharding_manager.go init"
echo ""
echo "   # 查看统计"
echo "   go run services/order-service/cmd/sharding_manager.go stats"
echo ""
echo "   # 运行测试"
echo "   go run services/order-service/cmd/sharding_manager.go test"
echo ""
echo "📖 详细文档: services/order-service/docs/SHARDING_GUIDE.md"