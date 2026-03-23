-- ==========================================
-- SQL Tool 全面测试 - MySQL
-- 覆盖各种 SQL 类型：DDL, DML, DQL, 事务, 聚合, 连接, 子查询等
-- ==========================================

-- 1. DDL 测试 - 创建数据库（如果不存在）
-- CREATE DATABASE IF NOT EXISTS sqltool_test;
-- USE sqltool_test;

-- 2. DDL 测试 - 创建表
DROP TABLE IF EXISTS test_orders;
DROP TABLE IF EXISTS test_users;

CREATE TABLE test_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100),
    age INT,
    salary DECIMAL(10,2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    birth_date DATE,
    info JSON
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE test_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_amount DECIMAL(10,2) NOT NULL,
    order_status VARCHAR(20) DEFAULT 'pending',
    order_date DATETIME NOT NULL,
    notes TEXT,
    FOREIGN KEY (user_id) REFERENCES test_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. DML 测试 - 插入数据
INSERT INTO test_users (username, email, age, salary, is_active, birth_date, info) VALUES
('zhangsan', 'zhangsan@example.com', 25, 8000.50, true, '1999-05-15', '{"department": "IT", "position": "developer"}'),
('lisi', 'lisi@example.com', 30, 12000.00, true, '1994-08-20', '{"department": "HR", "position": "manager"}'),
('wangwu', 'wangwu@example.com', 28, 10000.75, false, '1997-03-10', '{"department": "Finance", "position": "accountant"}'),
('zhaoliu', null, 35, 15000.25, true, '1989-12-25', null);

INSERT INTO test_orders (user_id, order_amount, order_status, order_date, notes) VALUES
(1, 100.50, 'completed', '2024-01-15 10:30:00', 'First order'),
(1, 250.75, 'pending', '2024-02-20 14:45:00', 'Second order'),
(2, 500.00, 'completed', '2024-01-25 09:15:00', 'Big order'),
(2, 75.25, 'cancelled', '2024-03-01 16:20:00', 'Cancelled order'),
(3, 300.00, 'completed', '2024-02-10 11:00:00', null);

-- 4. DQL 测试 - 基础查询
-- SELECT * FROM test_users;

-- 5. DQL 测试 - 条件查询
-- SELECT id, username, age, salary FROM test_users WHERE age > 25 AND is_active = true ORDER BY salary DESC;

-- 6. DQL 测试 - 聚合函数查询
-- SELECT
--     COUNT(*) AS total_users,
--     MIN(age) AS min_age,
--     MAX(age) AS max_age,
--     AVG(salary) AS avg_salary,
--     SUM(salary) AS total_salary
-- FROM test_users;

-- 7. DML 测试 - 更新数据
-- UPDATE test_users SET email = 'lisi_new@example.com', salary = 13000.00 WHERE username = 'lisi';

-- 8. DQL 测试 - 连接查询（INNER JOIN）
-- SELECT
--     u.username,
--     COUNT(o.order_id) AS order_count,
--     SUM(o.order_amount) AS total_order_amount
-- FROM test_users u
-- INNER JOIN test_orders o ON u.id = o.user_id
-- GROUP BY u.id, u.username
-- HAVING COUNT(o.order_id) > 0
-- ORDER BY total_order_amount DESC;

-- 9. DQL 测试 - 左连接查询
-- SELECT
--     u.username,
--     o.order_id,
--     o.order_amount,
--     o.order_status
-- FROM test_users u
-- LEFT JOIN test_orders o ON u.id = o.user_id
-- ORDER BY u.id, o.order_id;

-- 10. DQL 测试 - 子查询
-- SELECT username, salary
-- FROM test_users
-- WHERE salary > (SELECT AVG(salary) FROM test_users)
-- ORDER BY salary;

-- 11. DQL 测试 - LIKE 模糊查询
-- SELECT * FROM test_users WHERE username LIKE '%zhang%';

-- 12. DQL 测试 - IN 子句
-- SELECT * FROM test_users WHERE age IN (25, 30);

-- 13. DQL 测试 - IS NULL / IS NOT NULL
-- SELECT id, username, email FROM test_users WHERE email IS NULL;
-- SELECT id, username, info FROM test_users WHERE info IS NOT NULL;

-- 14. DML 测试 - 删除数据
-- DELETE FROM test_orders WHERE order_status = 'cancelled';

-- 15. DQL 测试 - 分页
-- SELECT * FROM test_users ORDER BY id LIMIT 2 OFFSET 0;

-- 16. DDL 测试 - 创建索引
-- CREATE INDEX idx_orders_user_id ON test_orders(user_id);
-- CREATE INDEX idx_orders_status ON test_orders(order_status);

-- 17. DDL 测试 - 显示表结构
-- DESCRIBE test_users;

-- 18. DDL 测试 - 显示索引
-- SHOW INDEX FROM test_orders;

-- 19. 事务测试 - MySQL 默认自动提交，这里测试多个语句
-- 注意：sqltool 一次执行一条命令，所以单独测试

-- 20. 测试 NULL 处理
-- INSERT INTO test_users (username, age) VALUES ('nulluser', 40);
-- SELECT * FROM test_users WHERE username = 'nulluser';
