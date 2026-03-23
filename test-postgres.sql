-- ==========================================
-- SQL Tool 全面测试 - PostgreSQL
-- 覆盖各种 SQL 类型：DDL, DML, DQL, 事务, 聚合, 连接, 子查询, Postgres 特性等
-- ==========================================

-- 1. DDL 测试 - 创建表（如果不存在）
DROP TABLE IF EXISTS test_orders;
DROP TABLE IF EXISTS test_users;

CREATE TABLE test_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100),
    age INTEGER,
    salary NUMERIC(10,2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    birth_date DATE,
    info JSONB
);

CREATE TABLE test_orders (
    order_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    order_amount NUMERIC(10,2) NOT NULL,
    order_status VARCHAR(20) DEFAULT 'pending',
    order_date TIMESTAMP NOT NULL,
    notes TEXT,
    tags TEXT[],
    FOREIGN KEY (user_id) REFERENCES test_users(id) ON DELETE CASCADE
);

-- 2. DML 测试 - 插入数据
INSERT INTO test_users (username, email, age, salary, is_active, birth_date, info) VALUES
('zhangsan', 'zhangsan@example.com', 25, 8000.50, true, '1999-05-15', '{"department": "IT", "position": "developer"}'::jsonb),
('lisi', 'lisi@example.com', 30, 12000.00, true, '1994-08-20', '{"department": "HR", "position": "manager"}'::jsonb),
('wangwu', 'wangwu@example.com', 28, 10000.75, false, '1997-03-10', '{"department": "Finance", "position": "accountant"}'::jsonb),
('zhaoliu', null, 35, 15000.25, true, '1989-12-25', null);

INSERT INTO test_orders (user_id, order_amount, order_status, order_date, notes, tags) VALUES
(1, 100.50, 'completed', '2024-01-15 10:30:00', 'First order', ARRAY['online', 'electronics']),
(1, 250.75, 'pending', '2024-02-20 14:45:00', 'Second order', ARRAY['books']),
(2, 500.00, 'completed', '2024-01-25 09:15:00', 'Big order', ARRAY['furniture', 'sale']),
(2, 75.25, 'cancelled', '2024-03-01 16:20:00', 'Cancelled order', null),
(3, 300.00, 'completed', '2024-02-10 11:00:00', null, ARRAY['clothing']);

-- 3. DQL 测试 - 基础查询
-- SELECT * FROM test_users;

-- 4. DQL 测试 - 条件查询
-- SELECT id, username, age, salary FROM test_users WHERE age > 25 AND is_active = true ORDER BY salary DESC;

-- 5. DQL 测试 - 聚合函数查询
-- SELECT
--     COUNT(*) AS total_users,
--     MIN(age) AS min_age,
--     MAX(age) AS max_age,
--     AVG(salary) AS avg_salary,
--     SUM(salary) AS total_salary
-- FROM test_users;

-- 6. DML 测试 - 更新数据
-- UPDATE test_users SET email = 'lisi_new@example.com', salary = 13000.00 WHERE username = 'lisi';

-- 7. DQL 测试 - 内连接查询（INNER JOIN）
-- SELECT
--     u.username,
--     COUNT(o.order_id) AS order_count,
--     SUM(o.order_amount) AS total_order_amount
-- FROM test_users u
-- INNER JOIN test_orders o ON u.id = o.user_id
-- GROUP BY u.id, u.username
-- HAVING COUNT(o.order_id) > 0
-- ORDER BY total_order_amount DESC;

-- 8. DQL 测试 - 左连接查询
-- SELECT
--     u.username,
--     o.order_id,
--     o.order_amount,
--     o.order_status
-- FROM test_users u
-- LEFT JOIN test_orders o ON u.id = o.user_id
-- ORDER BY u.id, o.order_id;

-- 9. DQL 测试 - 子查询
-- SELECT username, salary
-- FROM test_users
-- WHERE salary > (SELECT AVG(salary) FROM test_users)
-- ORDER BY salary;

-- 10. DQL 测试 - LIKE 模糊查询
-- SELECT * FROM test_users WHERE username LIKE '%zhang%';

-- 11. DQL 测试 - IN 子句
-- SELECT * FROM test_users WHERE age IN (25, 30);

-- 12. DQL 测试 - IS NULL / IS NOT NULL
-- SELECT id, username, email FROM test_users WHERE email IS NULL;
-- SELECT id, username, info FROM test_users WHERE info IS NOT NULL;

-- 13. DQL 测试 - Postgres JSONB 查询
-- SELECT username, info->>'department' AS department FROM test_users WHERE info IS NOT NULL;

-- 14. DQL 测试 - Postgres 数组查询
-- SELECT order_id, order_amount, tags FROM test_orders WHERE tags @> ARRAY['sale'];

-- 15. DML 测试 - 删除数据
-- DELETE FROM test_orders WHERE order_status = 'cancelled';

-- 16. DQL 测试 - 分页（LIMIT OFFSET）
-- SELECT * FROM test_users ORDER BY id LIMIT 2 OFFSET 0;

-- 17. DDL 测试 - 创建索引
-- CREATE INDEX idx_orders_user_id ON test_orders(user_id);
-- CREATE INDEX idx_orders_status ON test_orders(order_status);
-- CREATE INDEX idx_users_info ON test_users USING GIN(info);

-- 18. DDL 测试 - 显示表结构
-- SELECT column_name, data_type, is_nullable FROM information_schema.columns WHERE table_name = 'test_users';

-- 19. Postgres 特有 - 序列操作
-- SELECT last_value FROM test_users_id_seq;

-- 20. Postgres 特有 - 窗口函数
-- SELECT
--     username,
--     salary,
--     RANK() OVER (ORDER BY salary DESC) AS salary_rank
-- FROM test_users;

-- 21. 测试 NULL 处理
-- INSERT INTO test_users (username, age) VALUES ('nulluser', 40);
-- SELECT * FROM test_users WHERE username = 'nulluser';
