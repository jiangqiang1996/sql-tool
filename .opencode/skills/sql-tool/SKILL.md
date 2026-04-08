---
name: sql-tool
description: "通过 JDBC 执行任意数据库的 SQL 查询（MySQL、PostgreSQL、SQL Server、Oracle、SQLite、达梦、人大金仓、OceanBase 等所有提供 JDBC 驱动的数据库）。当需要查询、插入、更新、删除数据或执行 DDL/数据库管理操作时使用。"
---

# sql-tool 使用规范

> 目标：稳定执行数据库操作，避免常见的"命令错误 / 找不到可执行文件 / 驱动目录不存在 / 绝对路径换机失效"。

## 1. 路径约定

以下路径均相对于本技能根目录（即 SKILL.md 所在目录）：

- 可执行文件：`script/sql-tool.exe`
- 驱动目录：`script/drivers/`

### 强制约束

1. **禁止写绝对路径**。不要在命令或说明中写任何本机绝对路径。
2. **执行时设对工作目录**。把 `workdir` 设为技能根目录下的 `script/`，不要用 `cd ... &&` 串联。
3. **先检查驱动，再执行 SQL**。未准备好 JDBC 驱动时，不要直接执行 SQL。
4. **不要把示例连接信息当成仓库真相**。JDBC URL、用户名、密码应以用户明确提供的信息为准。

## 2. 调用前检查清单

执行前必须先确认：

1. JDBC URL 是否明确。
2. 数据库用户名 / 密码是否明确（SQLite 等嵌入式数据库除外）。
3. `script/sql-tool.exe` 是否存在。
4. `script/drivers/` 中是否已有匹配 JDBC URL 前缀的驱动 JAR。

任一项不满足时，先补齐信息或文件再继续。

## 3. JDBC URL 与驱动匹配

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

## 4. 强制执行流程

### 步骤 1：检查驱动

检查 `script/drivers/` 中是否已有匹配驱动。

- 已存在：直接执行。
- 不存在：先下载或让用户提供驱动。
- 不同版本但文件名匹配且可用时，不重复下载。

### 步骤 2：驱动缺失时补齐

下载到 `script/drivers/`。示例（workdir 为 drivers 目录）：

```bash
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.5/postgresql-42.7.5.jar' -OutFile 'postgresql.jar'"
```

自动下载失败时，直接向用户索要驱动 JAR 或下载链接。

### 步骤 3：执行 sql-tool

workdir 设为技能根目录下的 `script/`，显式传入 `-d "drivers"`。

## 5. 参数说明

| 短参数 | 长参数 | 必填 | 说明 |
|---|---|---|---|
| `-u` | `--url` | 是 | JDBC 连接地址 |
| `-user` | `--username` | 否* | 数据库用户名 |
| `-p` | `--password` | 否* | 数据库密码 |
| `-s` | `--sql` | 是 | 要执行的 SQL |
| `-d` | `--drivers-dir` | 否 | 驱动目录（默认为可执行文件同级的 `drivers` 目录） |
| `-h` | `--help` | 否 | 查看帮助 |

\* SQLite 等嵌入式数据库通常不需要用户名和密码。

## 6. 调用示例

以下命令均以技能根目录下的 `script/` 作为工作目录：

```bash
./sql-tool.exe -u "jdbc:postgresql://<host>:<port>/<db>" -user "<user>" -p "<pass>" -d "drivers" -s "SELECT 1"
```

```bash
./sql-tool.exe -u "jdbc:mysql://<host>:<port>/<db>" -user "<user>" -p "<pass>" -d "drivers" -s "SELECT * FROM users LIMIT 10"
```

```bash
./sql-tool.exe -u "jdbc:sqlite:./mydb.db" -d "drivers" -s "SELECT name FROM sqlite_master WHERE type='table'"
```

调试模式（输出完整堆栈）：

```bash
./sql-tool.exe -J-Dsql-tool.debug=true -u "..." -s "..."
```

## 7. 错误处理

| 错误现象 | 处理方式 |
|---|---|
| 找不到 `sql-tool.exe` | 确认 workdir 为 `script/` |
| `驱动目录不存在` / `驱动目录为空` | 确认 workdir 和 `drivers/` 下有匹配 JAR |
| `No suitable driver found` | 对照 JDBC 前缀检查驱动文件名；重新下载或向用户求助 |
| 无法连接数据库 | 确认 JDBC URL、数据库服务状态、端口 |
| 认证失败 | 核对凭据 |

## 8. 安全边界

1. 未经用户明确确认，不执行 `DROP DATABASE`、`DROP TABLE`、`TRUNCATE` 等破坏性操作。
2. 未经用户明确确认，不执行无 `WHERE` 条件的 `DELETE` 或 `UPDATE`。
3. 对于大结果集，只展示必要摘要和行数。

## 9. 实操建议

- 先做连通性验证（`SELECT 1`），再做写操作。
- PostgreSQL 管理动作（如创建数据库）建议先连接 `postgres` 维护库执行。
- 不确定表结构时，先查元数据或 `information_schema`。
- 只在 `script/drivers/` 目录存放驱动，不下载到临时目录或绝对路径。
