#!/bin/bash

# 微服务数据库初始化脚本
# 为每个微服务创建独立的数据库

set -e

echo "开始初始化微服务数据库..."

# 等待PostgreSQL服务启动
echo "等待PostgreSQL服务启动..."
sleep 10

# 认证服务数据库
echo "创建认证服务数据库..."
docker exec postgres-auth psql -U postgres -c "CREATE DATABASE IF NOT EXISTS auth_db;"
docker exec postgres-auth psql -U postgres -d auth_db -f /docker-entrypoint-initdb.d/init-db-microservices.sql

# 用户服务数据库
echo "创建用户服务数据库..."
docker exec postgres-user psql -U postgres -c "CREATE DATABASE IF NOT EXISTS user_db;"
docker exec postgres-user psql -U postgres -d user_db -f /docker-entrypoint-initdb.d/init-db-microservices.sql

# 商品服务数据库
echo "创建商品服务数据库..."
docker exec postgres-product psql -U postgres -c "CREATE DATABASE IF NOT EXISTS product_db;"
docker exec postgres-product psql -U postgres -d product_db -f /docker-entrypoint-initdb.d/init-db-microservices.sql

# 订单服务数据库
echo "创建订单服务数据库..."
docker exec postgres-order psql -U postgres -c "CREATE DATABASE IF NOT EXISTS order_db;"
docker exec postgres-order psql -U postgres -d order_db -f /docker-entrypoint-initdb.d/init-db-microservices.sql

# 购物车服务数据库
echo "创建购物车服务数据库..."
docker exec postgres-cart psql -U postgres -c "CREATE DATABASE IF NOT EXISTS cart_db;"
docker exec postgres-cart psql -U postgres -d cart_db -f /docker-entrypoint-initdb.d/init-db-microservices.sql

# 支付服务数据库
echo "创建支付服务数据库..."
docker exec postgres-payment psql -U postgres -c "CREATE DATABASE IF NOT EXISTS payment_db;"
docker exec postgres-payment psql -U postgres -d payment_db -f /docker-entrypoint-initdb.d/init-db-microservices.sql

# 通知服务数据库
echo "创建通知服务数据库..."
docker exec postgres-notification psql -U postgres -c "CREATE DATABASE IF NOT EXISTS notification_db;"
docker exec postgres-notification psql -U postgres -d notification_db -f /docker-entrypoint-initdb.d/init-db-microservices.sql

echo "所有微服务数据库初始化完成！"