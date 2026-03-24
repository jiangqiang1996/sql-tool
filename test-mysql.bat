@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "EXE=target\jpackage-output\sql-tool\sql-tool.exe"
set "DRV=target\jpackage-output\sql-tool\drivers"
set "BASE=jdbc:mysql://localhost:3306"
set "PARAMS=?useSSL=false&allowPublicKeyRetrieval=true"
set "USER=root"
set "PASS=123456"
set "DB=sqltool_test"

echo ============================================================
echo  SQL Tool Test Suite - MySQL
echo ============================================================
echo.

REM ---- 1. DDL: CREATE DATABASE ----
echo [1] DDL - CREATE DATABASE
%EXE% --url "%BASE%%PARAMS%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE DATABASE IF NOT EXISTS %DB%"
if errorlevel 1 echo [FAIL] CREATE DATABASE

echo [2] USE database (verify via JDBC URL)
%EXE% --url "%BASE%/%DB%%PARAMS%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT DATABASE() AS current_db"
if errorlevel 1 echo [FAIL] USE database

set "FURL=%BASE%/%DB%%PARAMS%"

REM ---- 3. DDL: CREATE TABLE ----
echo [3] DDL - CREATE TABLE
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP TABLE IF EXISTS test_orders"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP TABLE IF EXISTS test_users"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE TABLE test_users (id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(50) NOT NULL UNIQUE, email VARCHAR(100), age INT, salary DECIMAL(10,2), is_active BOOLEAN DEFAULT TRUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, birth_date DATE, info JSON)"
if errorlevel 1 echo [FAIL] CREATE TABLE test_users
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE TABLE test_orders (order_id INT AUTO_INCREMENT PRIMARY KEY, user_id INT NOT NULL, order_amount DECIMAL(10,2) NOT NULL, order_status VARCHAR(20) DEFAULT 'pending', order_date DATETIME NOT NULL, notes TEXT, FOREIGN KEY (user_id) REFERENCES test_users(id) ON DELETE CASCADE)"
if errorlevel 1 echo [FAIL] CREATE TABLE test_orders

REM ---- 4. DML: INSERT single row ----
echo [4] DML - INSERT single row
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "INSERT INTO test_users (username, email, age, salary, is_active, birth_date, info) VALUES ('zhangsan', 'zhangsan@example.com', 25, 8000.50, TRUE, '1999-05-15', JSON_OBJECT('department', 'IT', 'position', 'developer'))"
if errorlevel 1 echo [FAIL] INSERT single

REM ---- 5. DML: INSERT multi-row ----
echo [5] DML - INSERT multi-row
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "INSERT INTO test_users (username, email, age, salary, is_active, birth_date, info) VALUES ('lisi', 'lisi@example.com', 30, 12000.00, TRUE, '1994-08-20', JSON_OBJECT('department', 'HR')), ('wangwu', 'wangwu@example.com', 28, 10000.75, FALSE, '1997-03-10', JSON_OBJECT('department', 'Finance')), ('zhaoliu', NULL, 35, 15000.25, TRUE, '1989-12-25', NULL)"
if errorlevel 1 echo [FAIL] INSERT multi-row
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "INSERT INTO test_orders (user_id, order_amount, order_status, order_date, notes) VALUES (1, 100.50, 'completed', '2024-01-15 10:30:00', 'First order'), (1, 250.75, 'pending', '2024-02-20 14:45:00', 'Second order'), (2, 500.00, 'completed', '2024-01-25 09:15:00', 'Big order'), (2, 75.25, 'cancelled', '2024-03-01 16:20:00', 'Cancelled order'), (3, 300.00, 'completed', '2024-02-10 11:00:00', NULL)"
if errorlevel 1 echo [FAIL] INSERT multi-row orders

REM ---- 6. DML: INSERT ... SELECT ----
echo [6] DML - INSERT INTO ... SELECT (backup)
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE TABLE IF NOT EXISTS test_users_backup AS SELECT * FROM test_users WHERE 1=0"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "INSERT INTO test_users_backup SELECT * FROM test_users WHERE age > 25"
if errorlevel 1 echo [FAIL] INSERT ... SELECT

REM ---- 7. DQL: SELECT * ----
echo [7] DQL - SELECT *
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT * FROM test_users"
if errorlevel 1 echo [FAIL] SELECT *

REM ---- 8. DQL: WHERE + ORDER BY ----
echo [8] DQL - WHERE + ORDER BY
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT id, username, age, salary FROM test_users WHERE age > 25 AND is_active = TRUE ORDER BY salary DESC"
if errorlevel 1 echo [FAIL] WHERE

REM ---- 9. DQL: DISTINCT ----
echo [9] DQL - DISTINCT
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT DISTINCT order_status FROM test_orders"
if errorlevel 1 echo [FAIL] DISTINCT

REM ---- 10. DQL: Aggregate ----
echo [10] DQL - Aggregate (COUNT, MIN, MAX, AVG, SUM)
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT COUNT(*) AS total_users, MIN(age) AS min_age, MAX(age) AS max_age, AVG(salary) AS avg_salary, SUM(salary) AS total_salary FROM test_users"
if errorlevel 1 echo [FAIL] Aggregate

REM ---- 11. DQL: LIKE ----
echo [11] DQL - LIKE
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT * FROM test_users WHERE username LIKE '%%zhang%%'"
if errorlevel 1 echo [FAIL] LIKE

REM ---- 12. DQL: IN ----
echo [12] DQL - IN
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT * FROM test_users WHERE age IN (25, 30)"
if errorlevel 1 echo [FAIL] IN

REM ---- 13. DQL: BETWEEN ----
echo [13] DQL - BETWEEN
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT * FROM test_users WHERE age BETWEEN 25 AND 30"
if errorlevel 1 echo [FAIL] BETWEEN

REM ---- 14. DQL: IS NULL / IS NOT NULL ----
echo [14] DQL - IS NULL / IS NOT NULL
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT id, username, email FROM test_users WHERE email IS NULL"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT id, username, info FROM test_users WHERE info IS NOT NULL"
if errorlevel 1 echo [FAIL] IS NULL

REM ---- 15. DQL: INNER JOIN + GROUP BY + HAVING ----
echo [15] DQL - INNER JOIN + GROUP BY + HAVING
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT u.username, COUNT(o.order_id) AS order_count, SUM(o.order_amount) AS total_amount FROM test_users u INNER JOIN test_orders o ON u.id = o.user_id GROUP BY u.id, u.username HAVING COUNT(o.order_id) > 0 ORDER BY total_amount DESC"
if errorlevel 1 echo [FAIL] JOIN + GROUP BY + HAVING

REM ---- 16. DQL: LEFT JOIN ----
echo [16] DQL - LEFT JOIN
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT u.username, o.order_id, o.order_amount FROM test_users u LEFT JOIN test_orders o ON u.id = o.user_id ORDER BY u.id, o.order_id"
if errorlevel 1 echo [FAIL] LEFT JOIN

REM ---- 17. DQL: RIGHT JOIN ----
echo [17] DQL - RIGHT JOIN
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT o.order_id, u.username FROM test_orders o RIGHT JOIN test_users u ON o.user_id = u.id"
if errorlevel 1 echo [FAIL] RIGHT JOIN

REM ---- 18. DQL: CROSS JOIN ----
echo [18] DQL - CROSS JOIN
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT u.username, o.order_amount FROM test_users u CROSS JOIN test_orders o WHERE u.id = 1"
if errorlevel 1 echo [FAIL] CROSS JOIN

REM ---- 19. DQL: Subquery ----
echo [19] DQL - Subquery
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT username, salary FROM test_users WHERE salary > (SELECT AVG(salary) FROM test_users) ORDER BY salary"
if errorlevel 1 echo [FAIL] Subquery

REM ---- 20. DQL: EXISTS ----
echo [20] DQL - EXISTS
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT username FROM test_users u WHERE EXISTS (SELECT 1 FROM test_orders o WHERE o.user_id = u.id)"
if errorlevel 1 echo [FAIL] EXISTS

REM ---- 21. DQL: UNION ALL ----
echo [21] DQL - UNION ALL
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT username, 'user' AS source FROM test_users UNION ALL SELECT username, 'backup' AS source FROM test_users_backup"
if errorlevel 1 echo [FAIL] UNION ALL

REM ---- 22. DQL: CASE WHEN ----
echo [22] DQL - CASE WHEN
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT username, salary, CASE WHEN salary >= 10000 THEN 'high' WHEN salary >= 8000 THEN 'medium' ELSE 'low' END AS level FROM test_users"
if errorlevel 1 echo [FAIL] CASE WHEN

REM ---- 23. DQL: CTE (MySQL 8+) ----
echo [23] DQL - CTE (WITH ... AS)
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "WITH high_salary AS (SELECT * FROM test_users WHERE salary >= 10000) SELECT * FROM high_salary"
if errorlevel 1 echo [FAIL] CTE

REM ---- 24. DQL: Window function (MySQL 8+) ----
echo [24] DQL - Window function (RANK)
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT username, salary, RANK() OVER (ORDER BY salary DESC) AS salary_rank FROM test_users"
if errorlevel 1 echo [FAIL] Window function

REM ---- 25. DQL: Pagination ----
echo [25] DQL - Pagination (LIMIT OFFSET)
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT * FROM test_users ORDER BY id LIMIT 2 OFFSET 0"
if errorlevel 1 echo [FAIL] Pagination

REM ---- 26. DDL: CREATE VIEW ----
echo [26] DDL - CREATE VIEW
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE OR REPLACE VIEW v_active_users AS SELECT id, username, salary FROM test_users WHERE is_active = TRUE"
if errorlevel 1 echo [FAIL] CREATE VIEW
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT * FROM v_active_users"
if errorlevel 1 echo [FAIL] SELECT from VIEW

REM ---- 27. DDL: CREATE TABLE AS SELECT (backup table) ----
echo [27] DDL - CREATE TABLE AS SELECT (backup)
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP TABLE IF EXISTS test_orders_backup"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE TABLE test_orders_backup AS SELECT * FROM test_orders"
if errorlevel 1 echo [FAIL] CREATE TABLE AS SELECT
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT COUNT(*) AS cnt FROM test_orders_backup"

REM ---- 28. DDL: ALTER TABLE ADD COLUMN ----
echo [28] DDL - ALTER TABLE ADD COLUMN
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "ALTER TABLE test_users ADD COLUMN phone VARCHAR(20)"
if errorlevel 1 echo [FAIL] ALTER TABLE ADD COLUMN

REM ---- 29. DDL: ALTER TABLE RENAME COLUMN (MySQL 8+) ----
echo [29] DDL - ALTER TABLE RENAME COLUMN
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "ALTER TABLE test_users RENAME COLUMN phone TO mobile"
if errorlevel 1 echo [FAIL] ALTER TABLE RENAME COLUMN

REM ---- 30. DDL: RENAME TABLE (table rename) ----
echo [30] DDL - RENAME TABLE (table rename)
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE TABLE IF NOT EXISTS test_rename_target (id INT PRIMARY KEY, val VARCHAR(50))"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "RENAME TABLE test_rename_target TO test_renamed"
if errorlevel 1 echo [FAIL] RENAME TABLE
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT * FROM test_renamed"

REM ---- 31. DDL: CREATE INDEX ----
echo [31] DDL - CREATE INDEX
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE INDEX idx_users_age ON test_users(age)"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE INDEX idx_orders_status ON test_orders(order_status)"
if errorlevel 1 echo [FAIL] CREATE INDEX

REM ---- 32. DDL: SHOW INDEX / DESCRIBE ----
echo [32] DDL - SHOW INDEX / DESCRIBE
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SHOW INDEX FROM test_orders"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DESCRIBE test_users"
if errorlevel 1 echo [FAIL] SHOW / DESCRIBE

REM ---- 33. DDL: DROP INDEX ----
echo [33] DDL - DROP INDEX
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP INDEX idx_users_age ON test_users"
if errorlevel 1 echo [FAIL] DROP INDEX

REM ---- 34. DDL: DROP VIEW ----
echo [34] DDL - DROP VIEW
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP VIEW IF EXISTS v_active_users"
if errorlevel 1 echo [FAIL] DROP VIEW

REM ---- 35. DML: UPDATE ----
echo [35] DML - UPDATE
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "UPDATE test_users SET email = 'lisi_new@example.com', salary = 13000.00 WHERE username = 'lisi'"
if errorlevel 1 echo [FAIL] UPDATE

REM ---- 36. DML: UPDATE with subquery ----
echo [36] DML - UPDATE with subquery
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "UPDATE test_users SET is_active = FALSE WHERE id IN (SELECT user_id FROM test_orders WHERE order_status = 'cancelled')"
if errorlevel 1 echo [FAIL] UPDATE subquery

REM ---- 37. DML: DELETE ----
echo [37] DML - DELETE
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DELETE FROM test_orders WHERE order_status = 'cancelled'"
if errorlevel 1 echo [FAIL] DELETE

REM ---- 38. DML: DELETE with subquery ----
echo [38] DML - DELETE with subquery
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DELETE FROM test_users_backup WHERE age < (SELECT AVG(age) FROM test_users)"
if errorlevel 1 echo [FAIL] DELETE subquery

REM ---- 39. DML: TRUNCATE TABLE ----
echo [39] DML - TRUNCATE TABLE
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT COUNT(*) AS before_truncate FROM test_users_backup"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "TRUNCATE TABLE test_users_backup"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT COUNT(*) AS after_truncate FROM test_users_backup"
if errorlevel 1 echo [FAIL] TRUNCATE

REM ---- 40. DQL: JSON query (MySQL JSON) ----
echo [40] DQL - JSON query
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT username, JSON_EXTRACT(info, '$.department') AS department FROM test_users WHERE info IS NOT NULL"
if errorlevel 1 echo [FAIL] JSON query

REM ---- 41. DQL: NULL handling ----
echo [41] DQL - NULL handling (IFNULL, COALESCE)
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT username, IFNULL(email, 'no-email') AS email_display FROM test_users"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT username, COALESCE(info, '{}') AS info_safe FROM test_users"
if errorlevel 1 echo [FAIL] NULL handling

REM ---- 42. DDL: DROP DATABASE ----
echo [42] DDL - DROP DATABASE (temp)
%EXE% --url "%BASE%%PARAMS%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE DATABASE IF NOT EXISTS %DB%_temp"
%EXE% --url "%BASE%%PARAMS%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP DATABASE IF EXISTS %DB%_temp"
if errorlevel 1 echo [FAIL] DROP DATABASE

REM ---- 43. Final cleanup ----
echo [43] Cleanup - DROP all test tables
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP TABLE IF EXISTS test_renamed"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP TABLE IF EXISTS test_users_backup"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP TABLE IF EXISTS test_orders_backup"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP TABLE IF EXISTS test_orders"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP TABLE IF EXISTS test_users"
if errorlevel 1 echo [FAIL] Final cleanup

echo.
echo ============================================================
echo  MySQL Test Complete!
echo ============================================================
endlocal
