-- ==================================================
-- Go Shop 微服务平台 - 测试数据种子脚本
-- ==================================================

-- 插入测试用户数据
INSERT INTO `users` (`username`, `email`, `password`, `phone`, `status`, `created_at`, `updated_at`) VALUES
('admin', 'admin@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKXMf0jEfVLddAD7CPCwQk4V1wme', '13800138001', 1, NOW(3), NOW(3)),
('test_user', 'test@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKXMf0jEfVLddAD7CPCwQk4V1wme', '13800138002', 1, NOW(3), NOW(3)),
('demo_user', 'demo@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKXMf0jEfVLddAD7CPCwQk4V1wme', '13800138003', 1, NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `updated_at` = NOW(3);

-- 插入产品分类数据
INSERT INTO `categories` (`name`, `description`, `parent_id`, `sort_order`, `status`, `created_at`, `updated_at`) VALUES
('电子产品', '各类电子设备和配件', 0, 1, 1, NOW(3), NOW(3)),
('服装鞋帽', '时尚服装和鞋帽配饰', 0, 2, 1, NOW(3), NOW(3)),
('家居生活', '家居用品和生活必需品', 0, 3, 1, NOW(3), NOW(3)),
('图书音像', '图书、音乐和影视产品', 0, 4, 1, NOW(3), NOW(3)),
('运动户外', '运动器材和户外用品', 0, 5, 1, NOW(3), NOW(3)),
('手机数码', '手机及数码产品', 1, 1, 1, NOW(3), NOW(3)),
('电脑办公', '电脑及办公设备', 1, 2, 1, NOW(3), NOW(3)),
('男装', '男士服装', 2, 1, 1, NOW(3), NOW(3)),
('女装', '女士服装', 2, 2, 1, NOW(3), NOW(3)),
('童装', '儿童服装', 2, 3, 1, NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `updated_at` = NOW(3);

-- 插入测试产品数据
INSERT INTO `products` (`name`, `description`, `sku`, `category_id`, `price`, `cost_price`, `market_price`, `stock`, `min_stock`, `status`, `is_featured`, `created_at`, `updated_at`) VALUES
('iPhone 15 Pro', '苹果最新旗舰手机，配备A17 Pro芯片', 'IPHONE15PRO128', 6, 7999.00, 6500.00, 8999.00, 50, 5, 1, 1, NOW(3), NOW(3)),
('MacBook Pro 14', '专业级笔记本电脑，M3芯片', 'MBP14M3512', 7, 14999.00, 12000.00, 16999.00, 20, 2, 1, 1, NOW(3), NOW(3)),
('AirPods Pro', '主动降噪无线耳机', 'AIRPODSPRO2', 6, 1999.00, 1500.00, 2399.00, 100, 10, 1, 1, NOW(3), NOW(3)),
('Nike Air Force 1', '经典白色运动鞋', 'NIKEAF1WHITE42', 5, 899.00, 600.00, 1099.00, 80, 5, 1, 0, NOW(3), NOW(3)),
('Adidas Ultraboost', '缓震跑步鞋', 'ADIDASUB22BLK43', 5, 1299.00, 800.00, 1599.00, 60, 5, 1, 1, NOW(3), NOW(3)),
('Uniqlo基础T恤', '纯棉舒适T恤衫', 'UNIQLOBASICT1', 8, 99.00, 50.00, 149.00, 200, 20, 1, 0, NOW(3), NOW(3)),
('Zara女士连衣裙', '优雅修身连衣裙', 'ZARADRESS001M', 9, 299.00, 150.00, 399.00, 30, 3, 1, 1, NOW(3), NOW(3)),
('小米空气净化器', '智能家用空气净化器', 'MIAIRPURIFIER4', 3, 899.00, 600.00, 1299.00, 40, 5, 1, 1, NOW(3), NOW(3)),
('Kindle Paperwhite', '电子书阅读器', 'KINDLEPW11TH', 4, 898.00, 600.00, 1098.00, 25, 3, 1, 0, NOW(3), NOW(3)),
('乐高积木城堡', '儿童益智拼装玩具', 'LEGOCASTLE2024', 10, 599.00, 300.00, 799.00, 15, 2, 1, 1, NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `updated_at` = NOW(3);

-- 插入用户地址数据
INSERT INTO `user_addresses` (`user_id`, `name`, `phone`, `province`, `city`, `district`, `address`, `postal_code`, `is_default`, `created_at`, `updated_at`) VALUES
(1, '张三', '13800138001', '北京市', '北京市', '朝阳区', '三里屯街道工体北路1号', '100027', 1, NOW(3), NOW(3)),
(2, '李四', '13800138002', '上海市', '上海市', '浦东新区', '陆家嘴环路1000号', '200120', 1, NOW(3), NOW(3)),
(3, '王五', '13800138003', '广东省', '深圳市', '南山区', '科技园南区深南大道9999号', '518057', 1, NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `updated_at` = NOW(3);

-- 插入购物车测试数据
INSERT INTO `carts` (`user_id`, `product_id`, `quantity`, `price`, `created_at`, `updated_at`) VALUES
(2, 1, 1, 7999.00, NOW(3), NOW(3)),
(2, 3, 2, 1999.00, NOW(3), NOW(3)),
(3, 4, 1, 899.00, NOW(3), NOW(3)),
(3, 7, 1, 299.00, NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `updated_at` = NOW(3);

-- 插入测试订单数据
INSERT INTO `orders` (`order_no`, `user_id`, `total_amount`, `discount_amount`, `shipping_amount`, `final_amount`, `status`, `payment_status`, `shipping_address`, `created_at`, `updated_at`) VALUES
(CONCAT('ORD', DATE_FORMAT(NOW(), '%Y%m%d'), '001'), 1, 7999.00, 0.00, 0.00, 7999.00, 'completed', 'paid', JSON_OBJECT('name', '张三', 'phone', '13800138001', 'address', '北京市朝阳区三里屯街道工体北路1号'), NOW(3), NOW(3)),
(CONCAT('ORD', DATE_FORMAT(NOW(), '%Y%m%d'), '002'), 2, 1198.00, 100.00, 20.00, 1118.00, 'shipped', 'paid', JSON_OBJECT('name', '李四', 'phone', '13800138002', 'address', '上海市浦东新区陆家嘴环路1000号'), NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `updated_at` = NOW(3);

-- 插入订单明细数据
INSERT INTO `order_items` (`order_id`, `product_id`, `product_name`, `product_sku`, `price`, `quantity`, `total_amount`, `created_at`, `updated_at`) VALUES
(1, 1, 'iPhone 15 Pro', 'IPHONE15PRO128', 7999.00, 1, 7999.00, NOW(3), NOW(3)),
(2, 4, 'Nike Air Force 1', 'NIKEAF1WHITE42', 899.00, 1, 899.00, NOW(3), NOW(3)),
(2, 7, 'Zara女士连衣裙', 'ZARADRESS001M', 299.00, 1, 299.00, NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `updated_at` = NOW(3);

-- 更新产品销售数量和浏览次数
UPDATE `products` SET `sale_count` = 1, `view_count` = FLOOR(RAND() * 1000) + 100 WHERE `id` = 1;
UPDATE `products` SET `sale_count` = 1, `view_count` = FLOOR(RAND() * 800) + 50 WHERE `id` = 4;
UPDATE `products` SET `sale_count` = 1, `view_count` = FLOOR(RAND() * 600) + 30 WHERE `id` = 7;
UPDATE `products` SET `view_count` = FLOOR(RAND() * 500) + 20 WHERE `id` IN (2, 3, 5, 6, 8, 9, 10);

-- 插入操作日志示例
INSERT INTO `operation_logs` (`user_id`, `operation`, `resource`, `resource_id`, `details`, `ip_address`, `status`, `created_at`, `updated_at`) VALUES
(1, 'CREATE', 'order', 1, JSON_OBJECT('order_no', CONCAT('ORD', DATE_FORMAT(NOW(), '%Y%m%d'), '001'), 'amount', 7999.00), '127.0.0.1', 'success', NOW(3), NOW(3)),
(2, 'CREATE', 'order', 2, JSON_OBJECT('order_no', CONCAT('ORD', DATE_FORMAT(NOW(), '%Y%m%d'), '002'), 'amount', 1118.00), '127.0.0.1', 'success', NOW(3), NOW(3)),
(1, 'LOGIN', 'user', 1, JSON_OBJECT('login_method', 'username'), '127.0.0.1', 'success', NOW(3), NOW(3)),
(2, 'LOGIN', 'user', 2, JSON_OBJECT('login_method', 'email'), '127.0.0.1', 'success', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `updated_at` = NOW(3);

COMMIT;

-- 查看插入结果统计
SELECT 
    '用户' as table_name, COUNT(*) as count FROM users
UNION ALL SELECT 
    '分类' as table_name, COUNT(*) as count FROM categories
UNION ALL SELECT 
    '产品' as table_name, COUNT(*) as count FROM products
UNION ALL SELECT 
    '地址' as table_name, COUNT(*) as count FROM user_addresses
UNION ALL SELECT 
    '购物车' as table_name, COUNT(*) as count FROM carts
UNION ALL SELECT 
    '订单' as table_name, COUNT(*) as count FROM orders
UNION ALL SELECT 
    '订单明细' as table_name, COUNT(*) as count FROM order_items
UNION ALL SELECT 
    '系统配置' as table_name, COUNT(*) as count FROM system_configs
UNION ALL SELECT 
    '操作日志' as table_name, COUNT(*) as count FROM operation_logs; 