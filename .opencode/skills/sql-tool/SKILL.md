---
name: sql-tool
description: "通过 JDBC 执行任意数据库的 SQL 查询（MySQL、PostgreSQL、SQL Server、Oracle、SQLite、达梦、人大金仓、OceanBase 等所有提供 JDBC 驱动的数据库）。当需要查询、插入、更新、删除数据或执行 DDL/数据库管理操作时使用。"
---

## 功能说明

通过 `sql-tool` 自定义工具提供直接的数据库访问能力，可以对任何提供 JDBC 驱动的数据库执行**任意合法的 SQL 语句**。

**工具位置**：`.opencode/tools/sql-tool/sql-tool.exe`
**驱动目录**：`.opencode/tools/sql-tool/drivers/`（初始为空，按需安装）

## ⚠️ 执行前必须检查驱动（重要）

> **不要盲目调用工具后根据错误再处理驱动问题。** 工具已内置前置检查，会明确报告驱动缺失。正确的流程是：

1. 根据 JDBC URL 的协议前缀确定需要哪种驱动
2. 检查 drivers 目录是否已有对应 JAR
3. 没有则先安装驱动，再调用工具

### JDBC URL 前缀 → 驱动映射表

| URL 前缀 | 数据库 | 驱动 JAR 文件名包含 |
|----------|--------|---------------------|
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

## 驱动安装流程

当需要安装驱动时，**按以下顺序尝试**（找到即停止）：

### 第一步：检查 drivers 目录

列出 `.opencode/tools/sql-tool/drivers/` 下的所有 `.jar` 文件，按上表匹配是否已有对应驱动。有则直接调用工具。

### 第二步：从本地 Maven 仓库复制

依次检查以下 Maven 仓库路径是否存在（选第一个存在的）：

1. 环境变量 `MAVEN_REPOSITORY` 指向的路径
2. `D:\develop\repository\`（本项目常用）
3. `~/.m2/repository/`（Linux/Mac 默认）
4. `C:\Users\<用户名>\.m2\repository\`（Windows 默认）

在仓库中按 Maven 坐标查找 JAR（取版本号最大的）：

| 数据库 | Maven 仓库中的路径 |
|--------|-------------------|
| MySQL | `mysql/mysql-connector-java/` 或 `com/mysql/mysql-connector-j/` |
| MariaDB | `org/mariadb/java/mariadb-java-client/` |
| PostgreSQL | `org/postgresql/postgresql/` |
| SQL Server | `com/microsoft/sqlserver/mssql-jdbc/` |
| Oracle | `com/oracle/database/jdbc/ojdbc11/` |
| SQLite | `org/xerial/sqlite-jdbc/` |
| 达梦 | `com/dameng/DmJdbcDriver18/` |
| 人大金仓 | `com/kingbase8/kingbase8/` 或 `cn/com/kingbase/kingbase8/` |

找到后用 `cp` 复制到 `.opencode/tools/sql-tool/drivers/`。

### 第三步：从 Maven Central 下载

构造下载 URL 并使用 `curl` 下载：

```
https://repo1.maven.org/maven2/<groupId用/分隔>/<artifactId>/<version>/<artifactId>-<version>.jar
```

已知可用版本（直接使用，无需搜索）：

| 数据库 | 下载命令 |
|--------|---------|
| MySQL | `curl -L -o drivers/mysql-connector-j.jar https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar` |
| PostgreSQL | `curl -L -o drivers/postgresql.jar https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.5/postgresql-42.7.5.jar` |
| SQL Server | `curl -L -o drivers/mssql-jdbc.jar https://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/12.8.1.jre11/mssql-jdbc-12.8.1.jre11.jar` |
| SQLite | `curl -L -o drivers/sqlite-jdbc.jar https://repo1.maven.org/maven2/org/xerial/sqlite-jdbc/3.47.2.0/sqlite-jdbc-3.47.2.0.jar` |

### 第四步：向用户提问

以上均失败时，直接询问用户：

> 无法自动获取 [数据库名称] 的 JDBC 驱动。请提供驱动 JAR 文件的本地路径或下载链接，我会复制到 drivers 目录。

## 参数说明

| 参数 | 必填 | 说明 |
|------|------|------|
| `url` | 是 | JDBC 连接地址 |
| `username` | 否* | 数据库用户名 |
| `password` | 否* | 数据库密码 |
| `sql` | 是 | 要执行的 SQL 语句 |
| `charset` | 否 | 输出字符集（默认：UTF-8） |

*SQLite 不需要用户名和密码。

## 常用 JDBC 连接地址

| 数据库 | 连接地址格式 |
|--------|-------------|
| MySQL | `jdbc:mysql://host:3306/dbname?useSSL=false&allowPublicKeyRetrieval=true` |
| PostgreSQL | `jdbc:postgresql://host:5432/dbname` |
| SQL Server | `jdbc:sqlserver://host:1433;databaseName=dbname` |
| Oracle | `jdbc:oracle:thin:@host:1521:ORCL` |
| SQLite | `jdbc:sqlite:path/to/file.db` |
| 达梦 | `jdbc:dm://host:5236/dbname` |
| 人大金仓 | `jdbc:kingbase8://host:54321/dbname` |
| OceanBase | `jdbc:oceanbase://host:2883/dbname` |

## 错误处理

工具会返回明确的错误信息，根据提示处理即可：

| 错误信息 | 原因 | 处理方式 |
|---------|------|---------|
| `sql-tool.exe 不存在` | 可执行文件缺失 | 重新构建项目 |
| `驱动目录不存在` / `驱动目录为空` | 未安装驱动 | 按驱动安装流程操作 |
| `No suitable driver found` | 驱动类型不匹配 | 安装正确的驱动 JAR |
| `Communications link failure` | 驱动正常，但无法连接数据库 | 检查数据库地址、端口、网络 |
| `Access denied` | 用户名或密码错误 | 确认凭据 |

## 安全规则

1. **严禁**在未与用户**明确确认**的情况下执行 `DROP DATABASE`、`DROP TABLE`、`TRUNCATE` 等破坏性 DDL
2. **严禁**执行没有 `WHERE` 条件的 `DELETE` 或 `UPDATE`，除非用户明确要求
3. 始终将查询结果清晰地展示给用户
4. 对于大结果集，注明行数并进行摘要，而非输出全部数据

## 最佳实践

- 探索表结构时：先用 `SELECT * FROM table_name LIMIT 10` 了解数据样貌
- 查看表结构：使用 `DESCRIBE table_name` 或查询 `information_schema.columns`
- 不确定表结构时：先查询元数据或询问用户
- SQL 中字符串值使用单引号包裹
