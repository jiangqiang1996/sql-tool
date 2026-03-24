@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "EXE=target\jpackage-output\sql-tool\sql-tool.exe"
set "DRV=target\jpackage-output\sql-tool\drivers"
set "URL=jdbc:postgresql://localhost:5432"
set "USER=postgres"
set "PASS=123456"
set "DB=ctis_db"

echo ============================================================
echo  SQL Tool Test Suite - PostgreSQL
echo ============================================================
echo.

set "FURL=%URL%/%DB%"

REM ---- 1. DDL: CREATE DATABASE ----
echo [1] DDL - CREATE DATABASE
%EXE% --url "%URL%/postgres" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE DATABASE sqltool_test_db"
if errorlevel 1 echo [FAIL] CREATE DATABASE

REM ---- 2. DDL: CREATE SCHEMA ----
echo [2] DDL - CREATE SCHEMA
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE SCHEMA IF NOT EXISTS test_schema"
if errorlevel 1 echo [FAIL] CREATE SCHEMA

REM ---- 3. DDL: DROP SCHEMA ----
echo [3] DDL - DROP SCHEMA (recreate + drop)
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE SCHEMA IF NOT EXISTS temp_drop_schema"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP SCHEMA IF EXISTS temp_drop_schema"
if errorlevel 1 echo [FAIL] DROP SCHEMA

REM ---- 4. DDL: CREATE TABLE ----
echo [4] DDL - CREATE TABLE
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP TABLE IF EXISTS test_orders"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP TABLE IF EXISTS test_users"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE TABLE test_users (id SERIAL PRIMARY KEY, username VARCHAR(50) NOT NULL UNIQUE, email VARCHAR(100), age INTEGER, salary NUMERIC(10,2), is_active BOOLEAN DEFAULT TRUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, birth_date DATE, info JSONB)"
if errorlevel 1 echo [FAIL] CREATE TABLE test_users
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE TABLE test_orders (order_id SERIAL PRIMARY KEY, user_id INTEGER NOT NULL, order_amount NUMERIC(10,2) NOT NULL, order_status VARCHAR(20) DEFAULT 'pending', order_date TIMESTAMP NOT NULL, notes TEXT, tags TEXT[], CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES test_users(id) ON DELETE CASCADE)"
if errorlevel 1 echo [FAIL] CREATE TABLE test_orders

REM ---- 5. DDL: CREATE TABLE in schema ----
echo [5] DDL - CREATE TABLE in schema
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE TABLE IF NOT EXISTS test_schema.test_data (id INT PRIMARY KEY, value VARCHAR(100))"
if errorlevel 1 echo [FAIL] CREATE TABLE in schema

REM ---- 6. DML: INSERT single row ----
echo [6] DML - INSERT single row
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "INSERT INTO test_users (username, email, age, salary, is_active, birth_date, info) VALUES ('zhangsan', 'zhangsan@example.com', 25, 8000.50, TRUE, '1999-05-15', jsonb_build_object('department', 'IT', 'position', 'developer'))"
if errorlevel 1 echo [FAIL] INSERT single

REM ---- 7. DML: INSERT multi-row ----
echo [7] DML - INSERT multi-row
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "INSERT INTO test_users (username, email, age, salary, is_active, birth_date, info) VALUES ('lisi', 'lisi@example.com', 30, 12000.00, TRUE, '1994-08-20', jsonb_build_object('department', 'HR')), ('wangwu', 'wangwu@example.com', 28, 10000.75, FALSE, '1997-03-10', jsonb_build_object('department', 'Finance')), ('zhaoliu', NULL, 35, 15000.25, TRUE, '1989-12-25', NULL)"
if errorlevel 1 echo [FAIL] INSERT multi-row
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "INSERT INTO test_orders (user_id, order_amount, order_status, order_date, notes, tags) VALUES (1, 100.50, 'completed', '2024-01-15 10:30:00', 'First order', ARRAY['online', 'electronics']), (1, 250.75, 'pending', '2024-02-20 14:45:00', 'Second order', ARRAY['books']), (2, 500.00, 'completed', '2024-01-25 09:15:00', 'Big order', ARRAY['furniture', 'sale']), (2, 75.25, 'cancelled', '2024-03-01 16:20:00', 'Cancelled order', NULL), (3, 300.00, 'completed', '2024-02-10 11:00:00', NULL, ARRAY['clothing'])"
if errorlevel 1 echo [FAIL] INSERT multi-row orders

REM ---- 8. DML: INSERT ... SELECT ----
echo [8] DML - INSERT INTO ... SELECT (backup)
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE TABLE IF NOT EXISTS test_users_backup AS SELECT * FROM test_users WHERE 1=0"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "INSERT INTO test_users_backup SELECT * FROM test_users WHERE age > 25"
if errorlevel 1 echo [FAIL] INSERT ... SELECT

REM ---- 9. DQL: SELECT * ----
echo [9] DQL - SELECT *
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT * FROM test_users"
if errorlevel 1 echo [FAIL] SELECT *

REM ---- 10. DQL: WHERE + ORDER BY ----
echo [10] DQL - WHERE + ORDER BY
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT id, username, age, salary FROM test_users WHERE age > 25 AND is_active = TRUE ORDER BY salary DESC"
if errorlevel 1 echo [FAIL] WHERE

REM ---- 11. DQL: DISTINCT ----
echo [11] DQL - DISTINCT
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT DISTINCT order_status FROM test_orders"
if errorlevel 1 echo [FAIL] DISTINCT

REM ---- 12. DQL: Aggregate ----
echo [12] DQL - Aggregate (COUNT, MIN, MAX, AVG, SUM)
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT COUNT(*) AS total_users, MIN(age) AS min_age, MAX(age) AS max_age, AVG(salary) AS avg_salary, SUM(salary) AS total_salary FROM test_users"
if errorlevel 1 echo [FAIL] Aggregate

REM ---- 13. DQL: LIKE ----
echo [13] DQL - LIKE
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT * FROM test_users WHERE username LIKE '%%zhang%%'"
if errorlevel 1 echo [FAIL] LIKE

REM ---- 14. DQL: ILIKE (Postgres-specific) ----
echo [14] DQL - ILIKE (case-insensitive)
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT * FROM test_users WHERE username ILIKE '%%ZHANG%%'"
if errorlevel 1 echo [FAIL] ILIKE

REM ---- 15. DQL: IN ----
echo [15] DQL - IN
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT * FROM test_users WHERE age IN (25, 30)"
if errorlevel 1 echo [FAIL] IN

REM ---- 16. DQL: BETWEEN ----
echo [16] DQL - BETWEEN
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT * FROM test_users WHERE age BETWEEN 25 AND 30"
if errorlevel 1 echo [FAIL] BETWEEN

REM ---- 17. DQL: IS NULL / IS NOT NULL ----
echo [17] DQL - IS NULL / IS NOT NULL
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT id, username, email FROM test_users WHERE email IS NULL"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT id, username, info FROM test_users WHERE info IS NOT NULL"
if errorlevel 1 echo [FAIL] IS NULL

REM ---- 18. DQL: INNER JOIN + GROUP BY + HAVING ----
echo [18] DQL - INNER JOIN + GROUP BY + HAVING
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT u.username, COUNT(o.order_id) AS order_count, SUM(o.order_amount) AS total_amount FROM test_users u INNER JOIN test_orders o ON u.id = o.user_id GROUP BY u.id, u.username HAVING COUNT(o.order_id) > 0 ORDER BY total_amount DESC"
if errorlevel 1 echo [FAIL] JOIN + GROUP BY + HAVING

REM ---- 19. DQL: LEFT JOIN ----
echo [19] DQL - LEFT JOIN
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT u.username, o.order_id, o.order_amount FROM test_users u LEFT JOIN test_orders o ON u.id = o.user_id ORDER BY u.id, o.order_id"
if errorlevel 1 echo [FAIL] LEFT JOIN

REM ---- 20. DQL: RIGHT JOIN ----
echo [20] DQL - RIGHT JOIN
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT o.order_id, u.username FROM test_orders o RIGHT JOIN test_users u ON o.user_id = u.id"
if errorlevel 1 echo [FAIL] RIGHT JOIN

REM ---- 21. DQL: FULL OUTER JOIN ----
echo [21] DQL - FULL OUTER JOIN
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT u.username, o.order_id FROM test_users u FULL OUTER JOIN test_orders o ON u.id = o.user_id WHERE o.order_id IS NULL OR u.id IS NULL"
if errorlevel 1 echo [FAIL] FULL OUTER JOIN

REM ---- 22. DQL: CROSS JOIN ----
echo [22] DQL - CROSS JOIN
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT u.username, o.order_amount FROM test_users u CROSS JOIN test_orders o WHERE u.id = 1"
if errorlevel 1 echo [FAIL] CROSS JOIN

REM ---- 23. DQL: Subquery ----
echo [23] DQL - Subquery
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT username, salary FROM test_users WHERE salary > (SELECT AVG(salary) FROM test_users) ORDER BY salary"
if errorlevel 1 echo [FAIL] Subquery

REM ---- 24. DQL: EXISTS ----
echo [24] DQL - EXISTS
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT username FROM test_users u WHERE EXISTS (SELECT 1 FROM test_orders o WHERE o.user_id = u.id)"
if errorlevel 1 echo [FAIL] EXISTS

REM ---- 25. DQL: UNION ALL ----
echo [25] DQL - UNION ALL
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT username, 'user' AS source FROM test_users UNION ALL SELECT username, 'backup' AS source FROM test_users_backup"
if errorlevel 1 echo [FAIL] UNION ALL

REM ---- 26. DQL: CASE WHEN ----
echo [26] DQL - CASE WHEN
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT username, salary, CASE WHEN salary >= 10000 THEN 'high' WHEN salary >= 8000 THEN 'medium' ELSE 'low' END AS level FROM test_users"
if errorlevel 1 echo [FAIL] CASE WHEN

REM ---- 27. DQL: CTE (WITH ... AS) ----
echo [27] DQL - CTE
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "WITH high_salary AS (SELECT * FROM test_users WHERE salary >= 10000) SELECT * FROM high_salary"
if errorlevel 1 echo [FAIL] CTE

REM ---- 28. DQL: Window function (RANK) ----
echo [28] DQL - Window function (RANK)
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT username, salary, RANK() OVER (ORDER BY salary DESC) AS salary_rank FROM test_users"
if errorlevel 1 echo [FAIL] Window function

REM ---- 29. DQL: Pagination ----
echo [29] DQL - Pagination (LIMIT OFFSET)
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT * FROM test_users ORDER BY id LIMIT 2 OFFSET 0"
if errorlevel 1 echo [FAIL] Pagination

REM ---- 30. DQL: JSONB query (Postgres-specific) ----
echo [30] DQL - JSONB query
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT username, info->>'department' AS department FROM test_users WHERE info IS NOT NULL"
if errorlevel 1 echo [FAIL] JSONB query

REM ---- 31. DQL: Array query (Postgres-specific) ----
echo [31] DQL - Array query
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT order_id, order_amount, tags FROM test_orders WHERE tags @> ARRAY['sale']"
if errorlevel 1 echo [FAIL] Array query

REM ---- 32. DDL: CREATE VIEW ----
echo [32] DDL - CREATE VIEW
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE OR REPLACE VIEW v_active_users AS SELECT id, username, salary FROM test_users WHERE is_active = TRUE"
if errorlevel 1 echo [FAIL] CREATE VIEW
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT * FROM v_active_users"
if errorlevel 1 echo [FAIL] SELECT from VIEW

REM ---- 33. DDL: CREATE TABLE AS SELECT (backup table) ----
echo [33] DDL - CREATE TABLE AS SELECT (backup)
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP TABLE IF EXISTS test_orders_backup"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE TABLE test_orders_backup AS SELECT * FROM test_orders"
if errorlevel 1 echo [FAIL] CREATE TABLE AS SELECT
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT COUNT(*) AS cnt FROM test_orders_backup"

REM ---- 34. DDL: ALTER TABLE ADD COLUMN ----
echo [34] DDL - ALTER TABLE ADD COLUMN
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "ALTER TABLE test_users ADD COLUMN IF NOT EXISTS phone VARCHAR(20)"
if errorlevel 1 echo [FAIL] ALTER TABLE ADD COLUMN

REM ---- 35. DDL: ALTER TABLE RENAME COLUMN ----
echo [35] DDL - ALTER TABLE RENAME COLUMN
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "ALTER TABLE test_users RENAME COLUMN phone TO mobile"
if errorlevel 1 echo [FAIL] ALTER TABLE RENAME COLUMN

REM ---- 36. DDL: ALTER TABLE RENAME TO (table rename) ----
echo [36] DDL - ALTER TABLE RENAME TO (rename table)
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE TABLE IF NOT EXISTS test_rename_target (id INT PRIMARY KEY, val VARCHAR(50))"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "ALTER TABLE test_rename_target RENAME TO test_renamed"
if errorlevel 1 echo [FAIL] ALTER TABLE RENAME TO
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT * FROM test_renamed"

REM ---- 37. DDL: ALTER SCHEMA RENAME (rename schema) ----
echo [37] DDL - ALTER SCHEMA RENAME (rename schema/database)
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE SCHEMA IF NOT EXISTS schema_to_rename"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "ALTER SCHEMA schema_to_rename RENAME TO schema_renamed"
if errorlevel 1 echo [FAIL] ALTER SCHEMA RENAME
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP SCHEMA IF EXISTS schema_renamed"

REM ---- 38. DDL: CREATE INDEX ----
echo [38] DDL - CREATE INDEX
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE INDEX idx_users_age ON test_users(age)"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE INDEX idx_orders_status ON test_orders(order_status)"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "CREATE INDEX idx_users_info ON test_users USING GIN(info)"
if errorlevel 1 echo [FAIL] CREATE INDEX

REM ---- 39. DDL: table structure query ----
echo [39] DDL - Query table structure
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT column_name, data_type, is_nullable FROM information_schema.columns WHERE table_name = 'test_users'"
if errorlevel 1 echo [FAIL] Query table structure

REM ---- 40. DDL: DROP INDEX ----
echo [40] DDL - DROP INDEX
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP INDEX IF EXISTS idx_users_age"
if errorlevel 1 echo [FAIL] DROP INDEX

REM ---- 41. DDL: DROP VIEW ----
echo [41] DDL - DROP VIEW
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP VIEW IF EXISTS v_active_users"
if errorlevel 1 echo [FAIL] DROP VIEW

REM ---- 42. DML: UPDATE ----
echo [42] DML - UPDATE
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "UPDATE test_users SET email = 'lisi_new@example.com', salary = 13000.00 WHERE username = 'lisi'"
if errorlevel 1 echo [FAIL] UPDATE

REM ---- 43. DML: UPDATE with subquery ----
echo [43] DML - UPDATE with subquery
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "UPDATE test_users SET is_active = FALSE WHERE id IN (SELECT user_id FROM test_orders WHERE order_status = 'cancelled')"
if errorlevel 1 echo [FAIL] UPDATE subquery

REM ---- 44. DML: DELETE ----
echo [44] DML - DELETE
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DELETE FROM test_orders WHERE order_status = 'cancelled'"
if errorlevel 1 echo [FAIL] DELETE

REM ---- 45. DML: DELETE with subquery ----
echo [45] DML - DELETE with subquery
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DELETE FROM test_users_backup WHERE age < (SELECT AVG(age) FROM test_users)"
if errorlevel 1 echo [FAIL] DELETE subquery

REM ---- 46. DML: TRUNCATE TABLE ----
echo [46] DML - TRUNCATE TABLE
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT COUNT(*) AS before_truncate FROM test_users_backup"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "TRUNCATE TABLE test_users_backup"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT COUNT(*) AS after_truncate FROM test_users_backup"
if errorlevel 1 echo [FAIL] TRUNCATE

REM ---- 47. DQL: NULL handling (COALESCE) ----
echo [47] DQL - NULL handling (COALESCE)
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT username, COALESCE(email, 'no-email') AS email_display FROM test_users"
if errorlevel 1 echo [FAIL] COALESCE

REM ---- 48. DQL: Schema-qualified SELECT ----
echo [48] DQL - Schema-qualified query
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT * FROM test_schema.test_data"
if errorlevel 1 echo [FAIL] Schema-qualified SELECT

REM ---- 49. DDL: SET search_path (equivalent of USE database/schema) ----
echo [49] DDL - SET search_path (equivalent of USE database/schema)
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SET search_path TO test_schema"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SELECT current_schema()"
if errorlevel 1 echo [FAIL] SET search_path
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "SET search_path TO public"

REM ---- 50. DDL: DROP DATABASE ----
echo [50] DDL - DROP DATABASE
%EXE% --url "%URL%/postgres" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP DATABASE IF EXISTS sqltool_test_db"
if errorlevel 1 echo [FAIL] DROP DATABASE

REM ---- 51. DDL: DROP SCHEMA cascade ----
echo [51] DDL - DROP SCHEMA CASCADE
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP TABLE test_schema.test_data"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP SCHEMA IF EXISTS test_schema"
if errorlevel 1 echo [FAIL] DROP SCHEMA CASCADE

REM ---- 52. Final cleanup ----
echo [52] Cleanup - DROP all test tables
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP TABLE IF EXISTS test_renamed"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP TABLE IF EXISTS test_users_backup"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP TABLE IF EXISTS test_orders_backup"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP TABLE IF EXISTS test_orders"
%EXE% --url "%FURL%" --username %USER% --password %PASS% --drivers-dir "%DRV%" --sql "DROP TABLE IF EXISTS test_users"
if errorlevel 1 echo [FAIL] Final cleanup

echo.
echo ============================================================
echo  PostgreSQL Test Complete!
echo ============================================================
endlocal
