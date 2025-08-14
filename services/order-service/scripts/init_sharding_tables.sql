-- 订单分表初始化脚本
-- 创建10个订单分表

-- 订单主表分表（orders_00 到 orders_09）
DO $$
DECLARE
    i INTEGER;
    table_name TEXT;
BEGIN
    FOR i IN 0..9 LOOP
        table_name := 'orders_' || LPAD(i::TEXT, 2, '0');
        
        EXECUTE format('
            CREATE TABLE IF NOT EXISTS %I (
                id SERIAL PRIMARY KEY,
                user_id INTEGER NOT NULL,
                order_number VARCHAR(50) UNIQUE NOT NULL,
                status VARCHAR(20) DEFAULT ''pending'',
                total_amount DECIMAL(10,2) NOT NULL,
                shipping_address JSONB,
                billing_address JSONB,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                deleted_at TIMESTAMP
            );
        ', table_name);
        
        -- 创建索引
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%I_user_id ON %I(user_id);', table_name, table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%I_status ON %I(status);', table_name, table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%I_created_at ON %I(created_at);', table_name, table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%I_order_number ON %I(order_number);', table_name, table_name);
    END LOOP;
END $$;

-- 订单项分表（order_items_00 到 order_items_09）
DO $$
DECLARE
    i INTEGER;
    table_name TEXT;
BEGIN
    FOR i IN 0..9 LOOP
        table_name := 'order_items_' || LPAD(i::TEXT, 2, '0');
        
        EXECUTE format('
            CREATE TABLE IF NOT EXISTS %I (
                id SERIAL PRIMARY KEY,
                order_id INTEGER NOT NULL,
                product_id INTEGER NOT NULL,
                quantity INTEGER NOT NULL,
                price DECIMAL(10,2) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        ', table_name);
        
        -- 创建索引
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%I_order_id ON %I(order_id);', table_name, table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%I_product_id ON %I(product_id);', table_name, table_name);
    END LOOP;
END $$;

-- 订单状态历史分表（order_status_history_00 到 order_status_history_09）
DO $$
DECLARE
    i INTEGER;
    table_name TEXT;
BEGIN
    FOR i IN 0..9 LOOP
        table_name := 'order_status_history_' || LPAD(i::TEXT, 2, '0');
        
        EXECUTE format('
            CREATE TABLE IF NOT EXISTS %I (
                id SERIAL PRIMARY KEY,
                order_id INTEGER NOT NULL,
                status VARCHAR(20) NOT NULL,
                note TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        ', table_name);
        
        -- 创建索引
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%I_order_id ON %I(order_id);', table_name, table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%I_status ON %I(status);', table_name, table_name);
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%I_created_at ON %I(created_at);', table_name, table_name);
    END LOOP;
END $$;

-- 创建视图（用于联合查询所有分表）
CREATE OR REPLACE VIEW all_orders AS
SELECT * FROM orders_00
UNION ALL
SELECT * FROM orders_01
UNION ALL
SELECT * FROM orders_02
UNION ALL
SELECT * FROM orders_03
UNION ALL
SELECT * FROM orders_04
UNION ALL
SELECT * FROM orders_05
UNION ALL
SELECT * FROM orders_06
UNION ALL
SELECT * FROM orders_07
UNION ALL
SELECT * FROM orders_08
UNION ALL
SELECT * FROM orders_09;

CREATE OR REPLACE VIEW all_order_items AS
SELECT * FROM order_items_00
UNION ALL
SELECT * FROM order_items_01
UNION ALL
SELECT * FROM order_items_02
UNION ALL
SELECT * FROM order_items_03
UNION ALL
SELECT * FROM order_items_04
UNION ALL
SELECT * FROM order_items_05
UNION ALL
SELECT * FROM order_items_06
UNION ALL
SELECT * FROM order_items_07
UNION ALL
SELECT * FROM order_items_08
UNION ALL
SELECT * FROM order_items_09;

CREATE OR REPLACE VIEW all_order_status_history AS
SELECT * FROM order_status_history_00
UNION ALL
SELECT * FROM order_status_history_01
UNION ALL
SELECT * FROM order_status_history_02
UNION ALL
SELECT * FROM order_status_history_03
UNION ALL
SELECT * FROM order_status_history_04
UNION ALL
SELECT * FROM order_status_history_05
UNION ALL
SELECT * FROM order_status_history_06
UNION ALL
SELECT * FROM order_status_history_07
UNION ALL
SELECT * FROM order_status_history_08
UNION ALL
SELECT * FROM order_status_history_09;

-- 插入测试数据到分表
-- 注意：这里需要根据user_id计算分表索引
-- 例如：user_id % 10 = 分表索引

-- 为分表orders_00插入测试数据
INSERT INTO orders_00 (user_id, order_number, status, total_amount, shipping_address, billing_address) VALUES
(10, 'ORD202401010001', 'pending', 299.99, '{"street": "123 Main St", "city": "New York", "state": "NY", "postal_code": "10001"}', '{"street": "123 Main St", "city": "New York", "state": "NY", "postal_code": "10001"}'),
(20, 'ORD202401010002', 'completed', 599.99, '{"street": "456 Oak Ave", "city": "Los Angeles", "state": "CA", "postal_code": "90001"}', '{"street": "456 Oak Ave", "city": "Los Angeles", "state": "CA", "postal_code": "90001"}');

-- 为分表orders_01插入测试数据
INSERT INTO orders_01 (user_id, order_number, status, total_amount, shipping_address, billing_address) VALUES
(11, 'ORD202401010003', 'shipped', 199.99, '{"street": "789 Pine Rd", "city": "Chicago", "state": "IL", "postal_code": "60601"}', '{"street": "789 Pine Rd", "city": "Chicago", "state": "IL", "postal_code": "60601"}'),
(21, 'ORD202401010004', 'pending', 399.99, '{"street": "321 Elm St", "city": "Houston", "state": "TX", "postal_code": "77001"}', '{"street": "321 Elm St", "city": "Houston", "state": "TX", "postal_code": "77001"}');

-- 插入对应的订单项数据
INSERT INTO order_items_00 (order_id, product_id, quantity, price) VALUES
(1, 101, 2, 149.99),
(1, 102, 1, 49.99),
(2, 103, 1, 599.99);

INSERT INTO order_items_01 (order_id, product_id, quantity, price) VALUES
(3, 104, 1, 199.99),
(4, 105, 2, 199.99);

-- 插入订单状态历史
INSERT INTO order_status_history_00 (order_id, status, note) VALUES
(1, 'pending', 'Order created'),
(1, 'processing', 'Payment received'),
(2, 'pending', 'Order created'),
(2, 'processing', 'Payment received'),
(2, 'shipped', 'Order shipped'),
(2, 'completed', 'Order delivered');

INSERT INTO order_status_history_01 (order_id, status, note) VALUES
(3, 'pending', 'Order created'),
(3, 'processing', 'Payment received'),
(3, 'shipped', 'Order shipped'),
(4, 'pending', 'Order created');

-- 创建函数用于根据user_id获取正确的分表名
CREATE OR REPLACE FUNCTION get_order_table_name(user_id INTEGER) RETURNS TEXT AS $$
BEGIN
    RETURN 'orders_' || LPAD((user_id % 10)::TEXT, 2, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_order_item_table_name(order_id INTEGER) RETURNS TEXT AS $$
BEGIN
    RETURN 'order_items_' || LPAD((order_id % 10)::TEXT, 2, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_order_status_history_table_name(order_id INTEGER) RETURNS TEXT AS $$
BEGIN
    RETURN 'order_status_history_' || LPAD((order_id % 10)::TEXT, 2, '0');
END;
$$ LANGUAGE plpgsql;