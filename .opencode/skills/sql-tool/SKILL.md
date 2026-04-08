---
name: sql-tool
description: 通过 JDBC 执行任意数据库的 SQL 查询（MySQL、PostgreSQL、SQL Server、Oracle、SQLite、达梦、人大金仓、OceanBase 等所有提供 JDBC 驱动的数据库）。当需要查询、插入、更新、删除数据或执行 DDL/数据库管理操作时使用。
---

## 角色

通过 JDBC 执行关系型数据库操作，包括查询、写入、DDL 和数据库管理。

## 何时使用

- 需要对关系型数据库执行已定型的 SQL。
- 需要查询数据、检查表结构或数据库状态。
- 需要执行经用户确认的写入或 DDL 操作。
- 数据库来源未明确时，先向用户确认连接信息，再继续执行。

## 边界

- 不负责 SQL 设计或改写。
- 不负责 Liquibase 脚本管理。
- 不负责表结构新增设计。
- 不把示例连接信息当成仓库真相；JDBC URL、用户名、密码以用户明确提供的信息为准。
- 未经用户明确确认，不执行 `DROP DATABASE`、`DROP TABLE`、`TRUNCATE` 等破坏性操作。
- 未经用户明确确认，不执行无 `WHERE` 条件的 `DELETE` 或 `UPDATE`。
- 对于大结果集，只展示必要摘要和行数。

## 执行规范

### 路径约定

以下路径均相对于本技能根目录（即 SKILL.md 所在目录）：

- 可执行文件：`script/sql-tool.exe`
- 驱动目录：`script/drivers/`

强制约束：

1. 禁止写绝对路径。不要在命令或说明中写任何本机绝对路径。
2. 执行时把 `workdir` 设为技能根目录下的 `script/`，不要用 `cd ... &&` 串联。
3. 先检查驱动，再执行 SQL。未准备好 JDBC 驱动时，不要直接执行 SQL。

### 调用前检查

任一项不满足时先补齐再继续：

1. JDBC URL 是否明确。
2. 数据库用户名 / 密码是否明确（SQLite 等嵌入式数据库除外）。
3. `script/sql-tool.exe` 是否存在。
4. `script/drivers/` 中是否已有匹配 JDBC URL 前缀的驱动 JAR。

### JDBC URL 与驱动匹配

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

驱动缺失时下载到 `script/drivers/`（workdir 为 drivers 目录）：

```bash
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.5/postgresql-42.7.5.jar' -OutFile 'postgresql.jar'"
```

自动下载失败时，直接向用户索要驱动 JAR 或下载链接。不同版本但文件名匹配且可用时，不重复下载。

### 参数

| 短参数 | 长参数 | 必填 | 说明 |
|---|---|---|---|
| `-u` | `--url` | 是 | JDBC 连接地址 |
| `-user` | `--username` | 否* | 数据库用户名 |
| `-p` | `--password` | 否* | 数据库密码 |
| `-s` | `--sql` | 是 | 要执行的 SQL |
| `-d` | `--drivers-dir` | 否 | 驱动目录（默认为可执行文件同级的 `drivers` 目录） |
| `-h` | `--help` | 否 | 查看帮助 |

\* SQLite 等嵌入式数据库通常不需要用户名和密码。

### 调用示例

以下命令均以技能根目录下的 `script/` 作为工作目录：

```bash
./sql-tool.exe -u "jdbc:postgresql://<host>:<port>/<db>" -user "<user>" -p "<pass>" -d "drivers" -s "SELECT 1"
```

```bash
./sql-tool.exe -u "jdbc:mysql://<host>:<port>/<db>" -user "<user>" -p "<pass>" -d "drivers" -s "SELECT * FROM users LIMIT 10"
```

调试模式（输出完整堆栈）：

```bash
./sql-tool.exe -J-Dsql-tool.debug=true -u "..." -s "..."
```

### 错误处理

| 错误现象 | 处理方式 |
|---|---|
| 找不到 `sql-tool.exe` | 确认 workdir 为 `script/` |
| `驱动目录不存在` / `驱动目录为空` | 确认 workdir 和 `drivers/` 下有匹配 JAR |
| `No suitable driver found` | 对照 JDBC 前缀检查驱动文件名；重新下载或向用户求助 |
| 无法连接数据库 | 确认 JDBC URL、数据库服务状态、端口 |
| 认证失败 | 核对凭据 |

### 实操建议

- 先做连通性验证（`SELECT 1`），再做写操作。
- PostgreSQL 管理动作（如创建数据库）建议先连接 `postgres` 维护库执行。
- 不确定表结构时，先查元数据或 `information_schema`。
- 只在 `script/drivers/` 目录存放驱动，不下载到临时目录或绝对路径。

## 输出

- SQL 执行结果（查询结果集、影响行数、DDL 执行确认）。
- 连通性验证结果。
- 驱动状态与补齐建议（如适用）。
