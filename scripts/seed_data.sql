-- 种子数据脚本
USE gin;

-- 插入测试用户数据
INSERT INTO users (name, email, phone, status) VALUES
('张三', 'zhangsan@example.com', '13800138001', 1),
('李四', 'lisi@example.com', '13800138002', 1),
('王五', 'wangwu@example.com', '13800138003', 1),
('赵六', 'zhaoliu@example.com', '13800138004', 1),
('孙七', 'sunqi@example.com', '13800138005', 1)
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- 插入测试产品数据
INSERT INTO products (name, description, price, stock, category, status) VALUES
('iPhone 15 Pro', '苹果最新旗舰手机，采用A17 Pro芯片', 7999.00, 50, '手机数码', 1),
('MacBook Pro 14', '专业级笔记本电脑，M3芯片加持', 14999.00, 30, '电脑办公', 1),
('AirPods Pro 3', '主动降噪无线耳机，空间音频体验', 1899.00, 100, '数码配件', 1),
('iPad Air 5', '轻薄便携平板电脑，M1芯片性能强劲', 4399.00, 80, '平板电脑', 1),
('Apple Watch Series 9', '智能手表，健康监测新升级', 2999.00, 120, '智能穿戴', 1),
('小米13 Ultra', '徕卡光学镜头，影像旗舰', 5999.00, 60, '手机数码', 1),
('华为Mate 60 Pro', '卫星通话，突破不可能', 6999.00, 40, '手机数码', 1),
('ThinkPad X1 Carbon', '商务笔记本，轻薄便携', 12999.00, 25, '电脑办公', 1),
('索尼WH-1000XM5', '顶级降噪耳机，音质出众', 2399.00, 70, '数码配件', 1),
('Switch OLED', '任天堂游戏主机，OLED屏幕升级', 2599.00, 45, '游戏娱乐', 1),
('Tesla Model 3', '电动汽车，智能驾驶', 235900.00, 5, '新能源车', 1),
('戴森V15', '无线吸尘器，强力清洁', 4590.00, 35, '家用电器', 1),
('米家扫地机器人', '智能清扫，激光导航', 1599.00, 90, '智能家居', 1),
('海信75英寸电视', '4K超高清，HDR显示', 3999.00, 20, '家用电器', 1),
('美的空调变频', '1.5匹变频空调，静音节能', 2899.00, 55, '家用电器', 1)
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- 为用户1创建购物车和购物车项（示例数据）
INSERT INTO carts (user_id) VALUES (1) ON DUPLICATE KEY UPDATE user_id=VALUES(user_id);

SET @cart_id = (SELECT id FROM carts WHERE user_id = 1);

INSERT INTO cart_items (cart_id, product_id, quantity, price) VALUES
(@cart_id, 1, 1, 7999.00),
(@cart_id, 3, 2, 1899.00)
ON DUPLICATE KEY UPDATE quantity=VALUES(quantity), price=VALUES(price);

-- 创建示例订单
INSERT INTO orders (order_no, user_id, total_amount, status, payment_method, shipping_addr, contact_phone, contact_name, remark) VALUES
('ORD202401150001001', 1, 11797.00, 'pending', 'alipay', '北京市朝阳区xxx路xxx号', '13800138001', '张三', '请尽快发货'),
('ORD202401140002001', 2, 14999.00, 'paid', 'wechat', '上海市浦东新区xxx路xxx号', '13800138002', '李四', ''),
('ORD202401130003001', 3, 4399.00, 'shipped', 'bank', '广州市天河区xxx路xxx号', '13800138003', '王五', '工作日配送')
ON DUPLICATE KEY UPDATE order_no=VALUES(order_no);

-- 插入订单项
INSERT INTO order_items (order_id, product_id, quantity, price, total) VALUES
-- 订单1的商品
((SELECT id FROM orders WHERE order_no = 'ORD202401150001001'), 1, 1, 7999.00, 7999.00),
((SELECT id FROM orders WHERE order_no = 'ORD202401150001001'), 3, 2, 1899.00, 3798.00),

-- 订单2的商品
((SELECT id FROM orders WHERE order_no = 'ORD202401140002001'), 2, 1, 14999.00, 14999.00),

-- 订单3的商品
((SELECT id FROM orders WHERE order_no = 'ORD202401130003001'), 4, 1, 4399.00, 4399.00)
ON DUPLICATE KEY UPDATE quantity=VALUES(quantity);

-- 更新产品库存（模拟已售出的数量）
UPDATE products SET stock = stock - 1 WHERE id = 1;  -- iPhone 15 Pro
UPDATE products SET stock = stock - 2 WHERE id = 3;  -- AirPods Pro 3  
UPDATE products SET stock = stock - 1 WHERE id = 2;  -- MacBook Pro 14
UPDATE products SET stock = stock - 1 WHERE id = 4;  -- iPad Air 5 