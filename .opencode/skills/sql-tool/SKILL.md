---
name: sql-tool
description: "通过 JDBC 执行任意数据库的 SQL 查询（MySQL、PostgreSQL、SQL Server、Oracle、SQLite、达梦、人大金仓、OceanBase 等所有提供 JDBC 驱动的数据库）。当需要查询、插入、更新、删除数据或执行 DDL/数据库管理操作时使用。"
---

# ⚠️ ⚠️ 强制前置流程：必须先检查驱动，再调用工具！

**90% 的错误都是因为没有执行这一步！必须严格遵循此流程：**

## 🚩 步骤 0：调用 sql-tool 之前必须做驱动检查

### 完整强制流程（不能跳过任何一步）

1. **识别驱动类型**：根据 JDBC URL 的协议前缀，从下表确定需要哪种驱动
2. **检查已存在驱动**：使用 `glob` 或 `ls` 检查 `drivers` 目录是否已有对应 JAR（按文件名匹配表匹配）
   - ✅ **如果找到匹配驱动**：**直接跳到最后执行 SQL**，**禁止重新下载**
   - ❌ **禁止重复下载**：即使存在不同版本，只要已有匹配的驱动文件就直接使用
   - ❌ 只有当驱动**确实缺失**或**损坏**时，才能下载新驱动
3. **如果驱动缺失**：直接从 Maven Central 下载（使用预设好的下载命令，无需搜索版本）
4. **如果下载失败**：向用户提问获取驱动
5. **驱动已准备好**：调用工具执行 SQL

## 🔍 JDBC URL 前缀 → 驱动文件名匹配表

（根据 URL 前缀，查找 drivers 目录中文件名包含关键词的 jar 包）

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

---

# 🔧 驱动安装详细流程

当驱动确实缺失时，按以下顺序尝试（找到即停止）：

## 第一步：检查 drivers 目录 ✅ **这里就是你需要先做的**

使用 `glob "**/*<keyword>*.jar"` 搜索驱动目录，如果找到匹配，则直接使用，不下载。

**示例（PostgreSQL）：**
```
glob pattern="**/*postgresql*.jar"
```
输出结果如果找到，直接执行 SQL，不进行下载。

## 第二步：从 Maven Central 直接下载（驱动缺失时）

使用预定义的下载命令（这些已经经过测试，可以直接使用）：

| 数据库 | 直接复制执行的下载命令 |
|--------|------------------------|
| MySQL | `cd ".opencode/tools/sql-tool/drivers" && curl -L -o mysql-connector-j.jar https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar` |
| PostgreSQL | `cd ".opencode/tools/sql-tool/drivers" && curl -L -o postgresql.jar https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.5/postgresql-42.7.5.jar` |
| SQL Server | `cd ".opencode/tools/sql-tool/drivers" && curl -L -o mssql-jdbc.jar https://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/12.8.1.jre11/mssql-jdbc-12.8.1.jre11.jar` |
| SQLite | `cd ".opencode/tools/sql-tool/drivers" && curl -L -o sqlite-jdbc.jar https://repo1.maven.org/maven2/org/xerial/sqlite-jdbc/3.47.2.0/sqlite-jdbc-3.47.2.0.jar` |

> 💡 说明：命令已经包含 `cd`，直接复制执行即可，从项目根目录执行。

## 第三步：下载失败处理

如果下载失败或找不到驱动，直接询问用户：
> 无法自动获取 [数据库名称] 的 JDBC 驱动。请提供驱动 JAR 文件的本地路径或下载链接，我会复制到 drivers 目录。

---

# 🚀 工具调用方法

## 功能说明

通过 `sql-tool` 自定义工具提供直接的数据库访问能力，可以对任何提供 JDBC 驱动的数据库执行**任意合法的 SQL 语句**。

**工具位置**：`.opencode/tools/sql-tool/sql-tool.exe`
**驱动目录**：`.opencode/tools/sql-tool/drivers/`

## ⚠️ 重要使用须知 - 必须从工具目录执行

**sql-tool 的工作目录必须是 `.opencode/tools/sql-tool/`，必须显式指定驱动目录。**

**正确用法**（必须记住）：
```bash
# 必须先 cd 到工具目录，再执行
cd ".opencode/tools/sql-tool" && "./sql-tool.exe" -u "jdbc:postgresql://localhost:5433/dbname" -user postgres -p "password" -d "drivers" -s "SELECT 1"
```

**错误用法**（必错）：
```bash
# 错误：从项目根目录执行，未指定驱动目录
".opencode/tools/sql-tool/sql-tool.exe" ...  # ❌ 会报错"驱动目录不存在"
```

## 参数说明（必须严格遵循格式）

必须使用命令行格式，通过 `bash` 工具调用。**必须指定 `--drivers-dir`**：

| 短参数 | 长参数 | 必填 | 说明 | 示例 |
|--------|--------|------|------|------|
| `-u` | `--url` | 是 | JDBC 连接地址 | `-u "jdbc:postgresql://localhost:5432/ctis_db"` |
| `-user` | `--username` | 否* | 数据库用户名 | `-user postgres` |
| `-p` | `--password` | 否* | 数据库密码 | `-p "123456"` |
| `-s` | `--sql` | 是 | 要执行的 SQL 语句 | `-s "SELECT * FROM users"` |
| `-d` | `--drivers-dir` | 是 | 驱动目录路径 | `-d "drivers"` |
| `-c` | `--charset` | 否 | 输出字符集 | `-c "UTF-8"` |

*SQLite 不需要用户名和密码。

## 标准调用示例

**正确调用格式**：
```bash
cd ".opencode/tools/sql-tool" && "./sql-tool.exe" \
  -u "jdbc:postgresql://localhost:5433/ctis_db" \
  -user postgres \
  -p "123456" \
  -d "drivers" \
  -s "SELECT 1"
```

对于多行 SQL（如建表）：
```bash
cd ".opencode/tools/sql-tool" && "./sql-tool.exe" -u "jdbc:postgresql://localhost:5433/db" -user postgres -p "123456" -d "drivers" -s "CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  ...
);"
```

# ❌ 错误处理

工具会返回明确的错误信息，根据提示处理即可：

| 错误信息 | 原因 | 处理方式 |
|---------|------|---------|
| `驱动目录不存在` / `驱动目录为空` | 驱动目录未创建 或 无驱动文件 | 1. 创建 `.opencode/tools/sql-tool/drivers/` 目录<br>2. 按**完整驱动安装流程**重新执行（先检查已存在驱动，再下载） |
| `No suitable driver found` | 驱动类型不匹配 或 驱动 JAR 损坏 | 1. 检查驱动文件名是否匹配 URL 前缀<br>2. **仅当驱动确实缺失或损坏时**，重新从 Maven 仓库获取或下载驱动<br>3. 如果驱动已存在，请检查文件名匹配规则 |
| `Communications link failure` | 驱动正常，但无法连接数据库 | 检查数据库地址、端口、网络，确认数据库正在运行 |
| `Access denied` | 用户名或密码错误 | 确认凭据 |

# 📚 常用 JDBC 连接地址

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

# 🔒 安全规则

1. **严禁**在未与用户**明确确认**的情况下执行 `DROP DATABASE`、`DROP TABLE`、`TRUNCATE` 等破坏性 DDL
2. **严禁**执行没有 `WHERE` 条件的 `DELETE` 或 `UPDATE`，除非用户明确要求
3. 始终将查询结果清晰地展示给用户
4. 对于大结果集，注明行数并进行摘要，而非输出全部数据

## 最佳实践

- 探索表结构时：先用 `SELECT * FROM table_name LIMIT 10` 了解数据样貌
- 查看表结构：使用 `DESCRIBE table_name` 或查询 `information_schema.columns`
- 不确定表结构时：先查询元数据或询问用户
- SQL 中字符串值使用单引号包裹
