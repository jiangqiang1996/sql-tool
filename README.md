# SQL Tool - 对 AI 友好的命令行数据库操作工具

一个功能强大的命令行工具，支持动态加载驱动、格式化输出和数据库管理能力，让 AI 能够轻松操作任意数据库。

## 功能特性

- **动态驱动加载**：将任意 JDBC 驱动放入 `drivers` 目录，工具会自动加载
- **支持任意数据库**：适用于任何提供 JDBC 驱动的数据库
- **支持任意 SQL**：执行查询、DML、DDL 和数据库管理命令
- **格式化输出**：结果以清晰的 ASCII 表格展示，便于 AI 解析
- **数据库管理**：内置用户管理支持（创建、列出、删除用户，授权权限）

## 支持的数据库

对于任意数据库，只要提供 JDBC 驱动 JAR 文件，放入 `drivers` 目录即可使用。`.opencode/skills/sql-tool/SKILL.md`AI可以使用此技能自动下载对应驱动：

> **说明**：对于国产数据库如 OceanBase、达梦、PolarDB 等，AI可能无法下载驱动，只需要你告诉AI驱动路径或者直接放入 `drivers` 目录即可。

## JDBC URL 与驱动匹配

下表列出了常见数据库的 JDBC URL 前缀和对应的驱动文件名匹配规则：

| URL 前缀 | 数据库 | 驱动 JAR 文件名包含 |
|---|---|---|
| `jdbc:mysql:` | MySQL | `mysql-connector` |
| `jdbc:mariadb:` | MariaDB | `mariadb-java-client` |
| `jdbc:postgresql:` | PostgreSQL | `postgresql` |
| `jdbc:sqlserver:` | SQL Server | `mssql-jdbc` |
| `jdbc:oracle:` | Oracle | `ojdbc` |
| `jdbc:sqlite:` | SQLite | `sqlite-jdbc` |
| `jdbc:dm:` | 达梦 | `DmJdbcDriver` |
| `jdbc:kingbase8:` | 人大金仓 | `kingbase8` |
| `jdbc:oceanbase:` | OceanBase | `oceanbase-client` |
| `jdbc:opengauss:` | GaussDB | `opengauss-jdbc` |

## 环境要求

如果无需基于源码构建，直接复制项目根目录下的 `.opencode` 目录到自己项目即可

- Java 17+
- Maven 3.6+

## 如何使用

运行项目根目录下的 `build.bat` 即可构建。

将项目根目录下的 `.opencode/skills` 复制到自己项目或者全局配置目录下，即可让你的 ai 拥有操作数据库的能力。

## 快速开始

### 1. 检查驱动

进入 `sql-tool` 脚本目录：

```bash
cd .opencode/skills/sql-tool/script
```

检查 `drivers` 目录下是否已有对应数据库的驱动 JAR 文件。如果没有，先下载驱动到 `drivers/` 目录：

```bash
# 示例：下载 PostgreSQL 驱动（PowerShell）
cd drivers
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.5/postgresql-42.7.5.jar' -OutFile 'postgresql.jar'"
cd ..
```

### 2. 测试连接

```bash
./sql-tool.exe -u "jdbc:postgresql://localhost:5432/postgres" -user "postgres" -p "password" -d "drivers" -s "SELECT 1"
```

连接成功后，你就可以执行任意 SQL 命令了。

## 使用示例

所有示例都假设工作目录为 `.opencode/skills/sql-tool/script/`。

### 连接并查询数据

```bash
# MySQL 查询示例
./sql-tool.exe -u "jdbc:mysql://localhost:3306/mydb" -user "root" -p "password" -d "drivers" -s "SELECT * FROM users LIMIT 10"
```

```bash
# SQLite 不需要用户名密码
./sql-tool.exe -u "jdbc:sqlite:./mydb.db" -d "drivers" -s "SELECT name FROM sqlite_master WHERE type='table'"
```

### 创建表

```bash
./sql-tool.exe -u "jdbc:postgresql://localhost:5432/mydb" -user "postgres" -p "password" -d "drivers" -s "
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
"
```

### 插入数据

```bash
./sql-tool.exe -u "jdbc:mysql://localhost:3306/mydb" -user "root" -p "password" -d "drivers" -s "
INSERT INTO users (name, email) VALUES ('张三', 'zhangsan@example.com')
"
```

### 创建数据库

```bash
# PostgreSQL 需要先连接到维护库
./sql-tool.exe -u "jdbc:postgresql://localhost:5432/postgres" -user "postgres" -p "password" -d "drivers" -s "CREATE DATABASE mynewdb"
```

### 查看帮助

```bash
./sql-tool.exe --help
```

## 参数说明

| 短参数 | 长参数 | 必填 | 说明 |
|---|---|---|---|
| `-u` | `--url` | 是 | JDBC 连接地址 |
| `-user` | `--username` | 否* | 数据库用户名 |
| `-p` | `--password` | 否* | 数据库密码 |
| `-s` | `--sql` | 是 | 要执行的 SQL |
| `-d` | `--drivers-dir` | 建议显式传入 | 驱动目录，建议固定写 `drivers` |
| `-h` | `--help` | 否 | 查看帮助 |

*SQLite 通常不需要用户名和密码。

## 常见问题（FAQ）

### Q: 提示 "No suitable driver found" 是什么原因？

A: 这通常是以下原因之一：

- 驱动 JAR 文件不存在于 `drivers` 目录
- 驱动类型与 JDBC URL 不匹配
- 驱动 JAR 文件损坏

解决方法：对照上方 **JDBC URL 与驱动匹配** 表，确认 `drivers` 目录中有正确的驱动文件。

### Q: 提示 "找不到 sql-tool.exe" 怎么办？

A: 你需要从正确的目录执行命令。`sql-tool.exe` 始终位于 `.opencode/skills/sql-tool/script/` 目录下。执行前请先进入该目录：

```bash
cd .opencode/skills/sql-tool/script
```

### Q: 提示 "驱动目录不存在" 或 "驱动目录为空"？

A: 有两种可能：

1. 你没有从 `script/` 目录执行命令
2. `drivers/` 目录下没有任何驱动 JAR 文件

解决方法：确认你在正确目录，并已经下载了对应数据库的驱动。

### Q: 无法连接数据库怎么办？

A: 请依次检查：

1. JDBC URL 格式是否正确
2. 数据库服务是否正在运行
3. 网络是否可以连通数据库端口
4. 防火墙是否允许连接

### Q: 认证失败（用户名或密码错误）怎么办？

A: 请核对数据库用户名和密码是否正确，注意特殊字符是否需要转义。

## 安全约定

1. 未经你明确确认，AI 不会执行 `DROP DATABASE`、`DROP TABLE`、`TRUNCATE` 等破坏性操作
2. 未经你明确确认，AI 不会执行无 `WHERE` 条件的 `DELETE` 或 `UPDATE`
3. 对于大结果集，只会展示必要摘要和行数

## 实操建议

- 先做连通性验证，再做写操作
- PostgreSQL 管理动作（如创建数据库）建议先连接 `postgres` 这样的维护库执行
- 不确定表结构时，先查元数据或 `information_schema`
- 只在当前仓库的 `.opencode/skills/sql-tool/script/drivers/` 目录存放驱动
