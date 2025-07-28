-- ==================================================
-- Go Shop 微服务平台 - 数据库初始化脚本
-- ==================================================

-- 创建用户表
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `email` varchar(100) NOT NULL COMMENT '邮箱',
  `password` varchar(255) NOT NULL COMMENT '密码',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  `status` tinyint(1) DEFAULT '1' COMMENT '状态：1-正常，0-禁用',
  `last_login_at` datetime(3) DEFAULT NULL COMMENT '最后登录时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_users_username` (`username`),
  UNIQUE KEY `idx_users_email` (`email`),
  KEY `idx_users_deleted_at` (`deleted_at`),
  KEY `idx_users_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 创建产品分类表
CREATE TABLE IF NOT EXISTS `categories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `name` varchar(100) NOT NULL COMMENT '分类名称',
  `description` text COMMENT '分类描述',
  `parent_id` bigint(20) unsigned DEFAULT '0' COMMENT '父分类ID',
  `sort_order` int(11) DEFAULT '0' COMMENT '排序',
  `status` tinyint(1) DEFAULT '1' COMMENT '状态：1-启用，0-禁用',
  PRIMARY KEY (`id`),
  KEY `idx_categories_deleted_at` (`deleted_at`),
  KEY `idx_categories_parent_id` (`parent_id`),
  KEY `idx_categories_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='产品分类表';

-- 创建产品表
CREATE TABLE IF NOT EXISTS `products` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `name` varchar(200) NOT NULL COMMENT '产品名称',
  `description` text COMMENT '产品描述',
  `sku` varchar(100) NOT NULL COMMENT '产品SKU',
  `category_id` bigint(20) unsigned NOT NULL COMMENT '分类ID',
  `price` decimal(10,2) NOT NULL COMMENT '价格',
  `cost_price` decimal(10,2) DEFAULT NULL COMMENT '成本价',
  `market_price` decimal(10,2) DEFAULT NULL COMMENT '市场价',
  `stock` int(11) DEFAULT '0' COMMENT '库存数量',
  `min_stock` int(11) DEFAULT '0' COMMENT '最小库存预警',
  `weight` decimal(8,2) DEFAULT NULL COMMENT '重量(kg)',
  `images` json DEFAULT NULL COMMENT '产品图片',
  `attributes` json DEFAULT NULL COMMENT '产品属性',
  `status` tinyint(1) DEFAULT '1' COMMENT '状态：1-上架，0-下架',
  `is_featured` tinyint(1) DEFAULT '0' COMMENT '是否推荐：1-是，0-否',
  `view_count` int(11) DEFAULT '0' COMMENT '浏览次数',
  `sale_count` int(11) DEFAULT '0' COMMENT '销售数量',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_products_sku` (`sku`),
  KEY `idx_products_deleted_at` (`deleted_at`),
  KEY `idx_products_category_id` (`category_id`),
  KEY `idx_products_status` (`status`),
  KEY `idx_products_price` (`price`),
  KEY `idx_products_is_featured` (`is_featured`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='产品表';

-- 创建购物车表
CREATE TABLE IF NOT EXISTS `carts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `user_id` bigint(20) unsigned NOT NULL COMMENT '用户ID',
  `product_id` bigint(20) unsigned NOT NULL COMMENT '产品ID',
  `quantity` int(11) NOT NULL DEFAULT '1' COMMENT '数量',
  `price` decimal(10,2) NOT NULL COMMENT '加入时的价格',
  PRIMARY KEY (`id`),
  KEY `idx_carts_deleted_at` (`deleted_at`),
  KEY `idx_carts_user_id` (`user_id`),
  KEY `idx_carts_product_id` (`product_id`),
  UNIQUE KEY `idx_carts_user_product` (`user_id`, `product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='购物车表';

-- 创建订单表
CREATE TABLE IF NOT EXISTS `orders` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `order_no` varchar(50) NOT NULL COMMENT '订单号',
  `user_id` bigint(20) unsigned NOT NULL COMMENT '用户ID',
  `total_amount` decimal(10,2) NOT NULL COMMENT '订单总金额',
  `discount_amount` decimal(10,2) DEFAULT '0.00' COMMENT '折扣金额',
  `shipping_amount` decimal(10,2) DEFAULT '0.00' COMMENT '运费',
  `final_amount` decimal(10,2) NOT NULL COMMENT '实付金额',
  `status` varchar(20) NOT NULL DEFAULT 'pending' COMMENT '订单状态',
  `payment_status` varchar(20) NOT NULL DEFAULT 'unpaid' COMMENT '支付状态',
  `payment_method` varchar(20) DEFAULT NULL COMMENT '支付方式',
  `payment_time` datetime(3) DEFAULT NULL COMMENT '支付时间',
  `shipping_address` json DEFAULT NULL COMMENT '收货地址',
  `shipping_time` datetime(3) DEFAULT NULL COMMENT '发货时间',
  `delivered_time` datetime(3) DEFAULT NULL COMMENT '送达时间',
  `notes` text COMMENT '订单备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_orders_order_no` (`order_no`),
  KEY `idx_orders_deleted_at` (`deleted_at`),
  KEY `idx_orders_user_id` (`user_id`),
  KEY `idx_orders_status` (`status`),
  KEY `idx_orders_payment_status` (`payment_status`),
  KEY `idx_orders_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单表';

-- 创建订单明细表
CREATE TABLE IF NOT EXISTS `order_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `order_id` bigint(20) unsigned NOT NULL COMMENT '订单ID',
  `product_id` bigint(20) unsigned NOT NULL COMMENT '产品ID',
  `product_name` varchar(200) NOT NULL COMMENT '产品名称快照',
  `product_sku` varchar(100) NOT NULL COMMENT '产品SKU快照',
  `product_image` varchar(255) DEFAULT NULL COMMENT '产品图片快照',
  `price` decimal(10,2) NOT NULL COMMENT '单价',
  `quantity` int(11) NOT NULL COMMENT '数量',
  `total_amount` decimal(10,2) NOT NULL COMMENT '小计',
  PRIMARY KEY (`id`),
  KEY `idx_order_items_deleted_at` (`deleted_at`),
  KEY `idx_order_items_order_id` (`order_id`),
  KEY `idx_order_items_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单明细表';

-- 创建用户地址表
CREATE TABLE IF NOT EXISTS `user_addresses` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `user_id` bigint(20) unsigned NOT NULL COMMENT '用户ID',
  `name` varchar(50) NOT NULL COMMENT '收货人姓名',
  `phone` varchar(20) NOT NULL COMMENT '收货人电话',
  `province` varchar(50) NOT NULL COMMENT '省份',
  `city` varchar(50) NOT NULL COMMENT '城市',
  `district` varchar(50) NOT NULL COMMENT '区县',
  `address` varchar(200) NOT NULL COMMENT '详细地址',
  `postal_code` varchar(10) DEFAULT NULL COMMENT '邮政编码',
  `is_default` tinyint(1) DEFAULT '0' COMMENT '是否默认地址',
  PRIMARY KEY (`id`),
  KEY `idx_user_addresses_deleted_at` (`deleted_at`),
  KEY `idx_user_addresses_user_id` (`user_id`),
  KEY `idx_user_addresses_is_default` (`is_default`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户地址表';

-- 创建系统配置表
CREATE TABLE IF NOT EXISTS `system_configs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `key` varchar(100) NOT NULL COMMENT '配置键',
  `value` text COMMENT '配置值',
  `description` varchar(255) DEFAULT NULL COMMENT '配置描述',
  `type` varchar(20) DEFAULT 'string' COMMENT '配置类型',
  `is_public` tinyint(1) DEFAULT '0' COMMENT '是否公开配置',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_system_configs_key` (`key`),
  KEY `idx_system_configs_deleted_at` (`deleted_at`),
  KEY `idx_system_configs_is_public` (`is_public`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';

-- 创建操作日志表
CREATE TABLE IF NOT EXISTS `operation_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL COMMENT '操作用户ID',
  `operation` varchar(100) NOT NULL COMMENT '操作类型',
  `resource` varchar(100) NOT NULL COMMENT '操作资源',
  `resource_id` bigint(20) unsigned DEFAULT NULL COMMENT '资源ID',
  `details` json DEFAULT NULL COMMENT '操作详情',
  `ip_address` varchar(45) DEFAULT NULL COMMENT 'IP地址',
  `user_agent` varchar(500) DEFAULT NULL COMMENT '用户代理',
  `status` varchar(20) DEFAULT 'success' COMMENT '操作状态',
  `error_message` text COMMENT '错误信息',
  PRIMARY KEY (`id`),
  KEY `idx_operation_logs_user_id` (`user_id`),
  KEY `idx_operation_logs_operation` (`operation`),
  KEY `idx_operation_logs_resource` (`resource`),
  KEY `idx_operation_logs_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表';

-- 插入默认系统配置
INSERT INTO `system_configs` (`key`, `value`, `description`, `type`, `is_public`) VALUES
('site_name', 'Go Shop', '网站名称', 'string', 1),
('site_description', '基于 Go + Gin 的微服务电商平台', '网站描述', 'string', 1),
('site_logo', '/assets/logo.png', '网站Logo', 'string', 1),
('currency', 'CNY', '默认货币', 'string', 1),
('timezone', 'Asia/Shanghai', '系统时区', 'string', 0),
('pagination_size', '20', '默认分页大小', 'number', 0),
('upload_max_size', '10485760', '上传文件最大大小(字节)', 'number', 0),
('jwt_expire_hours', '24', 'JWT过期时间(小时)', 'number', 0),
('email_enabled', 'false', '是否启用邮件服务', 'boolean', 0),
('sms_enabled', 'false', '是否启用短信服务', 'boolean', 0)
ON DUPLICATE KEY UPDATE `value` = VALUES(`value`);

-- 创建索引优化查询性能
CREATE INDEX idx_products_price_status ON products(price, status);
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
CREATE INDEX idx_orders_created_payment ON orders(created_at, payment_status);

COMMIT; 