# SQL Tool - 对 AI 友好的命令行数据库操作工具

一个功能强大的命令行工具，支持动态加载驱动、格式化输出和数据库管理能力，让 AI 能够轻松操作任意数据库。

## 功能特性

- **动态驱动加载**：将任意 JDBC 驱动放入 `drivers` 目录，工具会自动加载
- **支持任意数据库**：适用于任何提供 JDBC 驱动的数据库
- **支持任意 SQL**：执行查询、DML、DDL 和数据库管理命令
- **格式化输出**：结果以清晰的 ASCII 表格展示，便于 AI 解析
- **数据库管理**：内置用户管理支持（创建、列出、删除用户，授权权限）

## 支持的数据库

对于任意数据库，只要提供 JDBC 驱动 JAR 文件，放入 `drivers` 目录即可使用。常用数据库：

| 数据库 | 内置 Maven 依赖 | 动态驱动加载 | 用户管理支持 |
|--------|----------------|--------------|--------------|
| MySQL/MariaDB | ✅ 包含 | ✅ 支持 | ✅ 支持 |
| PostgreSQL | ✅ 包含 | ✅ 支持 | ✅ 支持 |
| SQL Server | ✅ 包含 | ✅ 支持 | ✅ 支持 |
| Oracle | ✅ 包含 | ✅ 支持 | ✅ 支持 |
| SQLite | ✅ 包含 | ✅ 支持 | ⚠️ 无用户系统 |

> **说明**：对于国产数据库如 OceanBase、达梦、PolarDB 等，只要提供 JDBC 驱动，放入 `drivers` 目录即可通过通用 JDBC 连接使用。但目前没有内置特定的用户管理 SQL 支持。

## 环境要求

- Java 17+
- Maven 3.6+

## 快速开始

### 从源码构建

```bash
git clone <repository-url>
cd sql-tool
mvn clean package
```

构建完成后，可执行 JAR 包位于 `target/sql-tool-1.0.0.jar`。

### 添加 JDBC 驱动

将你的 JDBC 驱动 JAR 文件放入 `drivers` 目录。常用驱动已经包含在 Maven 依赖中，如果版本不匹配可以将对应版本放入 `drivers` 目录覆盖。

常用连接 URL 示例：

| 数据库 | 连接 URL 示例 |
|----------|-------------|
| MySQL/MariaDB | `jdbc:mysql://localhost:3306/dbname` |
| PostgreSQL | `jdbc:postgresql://localhost:5432/dbname` |
| SQL Server | `jdbc:sqlserver://localhost:1433;databaseName=dbname` |
| Oracle | `jdbc:oracle:thin:@localhost:1521:ORCL` |
| SQLite | `jdbc:sqlite:database.db` |

## 使用方法

### 基本查询

```bash
java -jar target/sql-tool-1.0.0.jar --url <jdbc-url> --username <user> --password <pass> --sql "SELECT * FROM table_name"
```

### 命令行选项

```
SQL Operation Tool - Command Line Usage

Usage: sqltool [options] --url <jdbc-url> --sql <query>

Options:
  -u, --url <jdbc-url>       JDBC 连接 URL (必需)
  -user, --username <user>   数据库用户名
  -p, --password <pass>      数据库密码
  -s, --sql <query>          要执行的 SQL (必需)
  -d, --drivers-dir <path>   包含 JDBC 驱动的目录 (默认: ./drivers)
  -h, --help                 显示帮助信息

Examples:
  java -jar target/sql-tool-1.0.0.jar --url jdbc:mysql://localhost:3306/mydb --username root --password secret --sql "SELECT * FROM users"
  java -jar target/sql-tool-1.0.0.jar --url jdbc:postgresql://localhost:5432/mydb -user postgres -p postgres -s "CREATE TABLE test (id INT, name VARCHAR(255))"
```

### 使用示例

**查询数据：**
```bash
java -jar target/sql-tool-1.0.0.jar --url jdbc:mysql://localhost:3306/mydb --username root --password secret --sql "SELECT * FROM users"
```

**创建表：**
```bash
java -jar target/sql-tool-1.0.0.jar --url jdbc:postgresql://localhost:5432/mydb -user postgres -p secret -s "CREATE TABLE employees (id SERIAL PRIMARY KEY, name VARCHAR(100), salary DECIMAL(10,2))"
```

**插入数据：**
```bash
java -jar target/sql-tool-1.0.0.jar --url jdbc:mysql://localhost:3306/mydb --username root --password secret --sql "INSERT INTO users (name, email) VALUES ('张三', 'zhangsan@example.com')"
```

**简写形式：**
```bash
java -jar target/sql-tool-1.0.0.jar -u jdbc:sqlite:mydb.db -s "SELECT * FROM users"
```

## 输出格式

查询结果格式化为 ASCII 表格，便于阅读和解析：

```
Connected successfully to: jdbc:mysql://localhost:3306/mydb
Loading 1 driver(s) from drivers...
  Loading: mysql-connector-java-8.0.33.jar
    Found driver: com.mysql.cj.jdbc.Driver (com.mysql.cj.jdbc.Driver)
Loaded 1 driver(s) successfully
+----+----------+---------------------+
| id | name     | email               |
+----+----------+---------------------+
| 1  | 张三 | zhangsan@example.com |
| 2  | 李四 | lisi@example.com    |
+----+----------+---------------------+
2 row(s) returned

Disconnected from database
```

非查询操作（INSERT、UPDATE、CREATE 等）显示影响行数：

```
Query executed successfully. Rows affected: 1
```
Connected successfully to: jdbc:mysql://localhost:3306/mydb
Loading 1 driver(s) from drivers...
  Loading: mysql-connector-java-8.0.33.jar
    Found driver: com.mysql.cj.jdbc.Driver (com.mysql.cj.jdbc.Driver)
Loaded 1 driver(s) successfully
+----+----------+---------------------+
| id | name     | email               |
+----+----------+---------------------+
| 1  | 张三 | zhangsan@example.com |
| 2  | 李四 | lisi@example.com    |
+----+----------+---------------------+
2 row(s) returned

Disconnected from database
```

非查询操作（INSERT、UPDATE、CREATE 等）显示影响行数：

```
Query executed successfully. Rows affected: 1
```

## 数据库管理

虽然你可以直接执行任意 SQL，但 SQL Tool 也内置了常见操作的数据库管理能力。你可以通过包装脚本或扩展 CLI 来使用这些功能。

支持主流数据库的以下操作：

- **列出用户**：获取所有数据库用户
- **创建用户**：创建带密码的新数据库用户
- **授权权限**：授予用户对数据库的所有权限
- **删除用户**：移除数据库用户

管理 API 感知数据库差异，为以下数据库生成正确的 SQL：
- **MySQL / MariaDB** - 完整支持
- **PostgreSQL** - 完整支持
- **SQL Server** - 完整支持
- **Oracle** - 完整支持

对于其他数据库，你仍然可以通过直接执行 SQL 完成管理操作。

## 项目架构

```
sql-tool/
├── drivers/                    # 外部 JDBC 驱动目录（动态加载）
│   └── README.md
├── src/main/java/top/jiangqiang/tools/
│   ├── SqlTool.java            # 主入口
│   ├── cli/
│   │   └── CommandLineArgs.java    # CLI 参数解析
│   ├── connection/
│   │   ├── ConnectionConfig.java  # 连接配置
│   │   └── DriverLoader.java      # 从磁盘动态加载驱动
│   ├── execution/
│   │   └── SqlExecutor.java       # SQL 执行处理
│   ├── formatting/
│   │   └── ResultFormatter.java   # ASCII 表格格式化
│   └── management/
│       └── DatabaseManagement.java # 数据库特定管理
└── pom.xml
```

### 关键设计点

1. **动态类加载**：JDBC 驱动在运行时通过自定义 URLClassLoader 从 `drivers` 目录加载。这允许添加新驱动而无需重新构建工具。

2. **驱动适配层**：包装层使动态加载的驱动与 JDBC DriverManager 兼容。

3. **任意 SQL 支持**：工具不对你可执行的 SQL 进行限制 - 可以传递任何有效的 SQL 语句给数据库。

4. **格式化输出**：结果格式化为 ASCII 表格，既便于人类阅读，也易于 AI 系统解析。

## AI 集成

该工具专门设计用于 AI 代理使用。结构化输出格式使 AI 能够轻松：
- 理解查询结果
- 验证操作是否成功完成
- 从数据库表提取数据
- 通过自然语言执行数据库管理

AI 交互示例：
```
用户：给我展示本地 MySQL 数据库中的所有用户
AI：调用：java -jar target/sql-tool-1.0.0.jar --url jdbc:mysql://localhost:3306/mysql --username root --password secret --sql "SELECT * FROM user"
AI：读取格式化输出并将信息呈现给用户
```



## 问题排查

### "No JAR files found in drivers"
- 确保你已将 JDBC 驱动 JAR 放入 `drivers` 目录
- 检查文件扩展名是 `.jar`（不区分大小写）

### "Cannot load driver class"
- 驱动 JAR 可能缺少依赖
- 确保你拥有对应数据库版本的正确驱动 JAR
- 检查驱动支持你的 Java 版本

### "No suitable driver found for jdbc:..."
- 检查 JDBC URL 格式与驱动期望匹配
- 确保驱动 JAR 包含 `java.sql.Driver` 实现
- 验证驱动 JAR 确实位于 drivers 目录中

## 许可证

MIT 许可证 - 你可以随意用于任何目的。
