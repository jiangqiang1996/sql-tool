---
name: sql-tool
description: "通过 JDBC 执行任意数据库的 SQL 查询（MySQL、PostgreSQL、SQL Server、Oracle、SQLite、达梦、人大金仓、OceanBase 等所有提供 JDBC 驱动的数据库）。当需要查询、插入、更新、删除数据或执行 DDL/数据库管理操作时使用。"
---

# sql-tool 使用规范

> 目标：稳定执行数据库操作，避免常见的“命令错误 / 找不到可执行文件 / 驱动目录不存在 / 绝对路径换机失效”。

## 1. live 路径真相

- skill 根目录：`@.opencode/skills/sql-tool/`
- 可执行文件：`@.opencode/skills/sql-tool/script/sql-tool.exe`
- 驱动目录：`@.opencode/skills/sql-tool/script/drivers/`

### 强制约束

1. **禁止写绝对路径**。不要在文档、命令或说明中写任何本机绝对路径。
2. **只以 live 文件系统为准**。当前仓库的 launcher 位于 `@.opencode/skills/sql-tool/script/`。
3. **执行时使用 repo 相对路径 + 正确工作目录**。不要依赖 `cd ... &&` 串联命令；应直接把工作目录设为 `@.opencode/skills/sql-tool/script/`。
4. **先检查驱动，再执行 SQL**。未准备好 JDBC 驱动时，不要直接执行 SQL。
5. **不要把示例连接信息当成仓库真相**。JDBC URL、用户名、密码、数据库名应以当前项目配置链或用户明确提供的信息为准。

## 2. 调用前检查清单

执行前必须先确认以下四件事：

1. JDBC URL 是否明确。
2. 数据库用户名 / 密码是否明确。
3. `@.opencode/skills/sql-tool/script/sql-tool.exe` 是否存在。
4. `@.opencode/skills/sql-tool/script/drivers/` 中是否已有匹配 JDBC URL 前缀的驱动 JAR。

如果上述任一项不满足，应先补齐信息或文件，再继续执行。

## 3. JDBC URL 前缀与驱动匹配

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

### 步骤 1：检查驱动是否已存在

先检查 `@.opencode/skills/sql-tool/script/drivers/` 中是否已有匹配驱动。

- 已存在匹配驱动：直接执行 SQL。
- 不存在匹配驱动：先下载或让用户提供驱动，再执行 SQL。
- 即使目录里有不同版本，只要文件名与目标数据库匹配且驱动可用，就不要重复下载。

### 步骤 2：驱动缺失时补齐驱动

优先把驱动下载到 `@.opencode/skills/sql-tool/script/drivers/`。

PostgreSQL 示例：

```bash
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.5/postgresql-42.7.5.jar' -OutFile 'postgresql.jar'"
```

> 说明：该命令应在 `@.opencode/skills/sql-tool/script/drivers/` 作为工作目录时执行。
> 如果当前环境没有 PowerShell，可改用当前环境已确认可用的下载命令，但**目标目录仍必须是这个 repo 相对目录**。

如果自动下载失败，直接向用户索要驱动 JAR 文件或下载链接。

### 步骤 3：从正确目录执行 sql-tool

`sql-tool.exe` 当前位于 `@.opencode/skills/sql-tool/script/`。调用时应把工作目录设为该目录，并显式传入 `-d "drivers"`，避免驱动目录解析歧义。

如果是通过 `bash` 工具调用，应把 `workdir` 设为 `@.opencode/skills/sql-tool/script/` 或 `@.opencode/skills/sql-tool/script/drivers/`，不要把切目录动作写进命令字符串。

## 5. 标准调用方式

### 参数说明

| 短参数 | 长参数 | 必填 | 说明 |
|---|---|---|---|
| `-u` | `--url` | 是 | JDBC 连接地址 |
| `-user` | `--username` | 否* | 数据库用户名 |
| `-p` | `--password` | 否* | 数据库密码 |
| `-s` | `--sql` | 是 | 要执行的 SQL |
| `-d` | `--drivers-dir` | 建议显式传入 | 驱动目录，建议固定写 `drivers` |
| `-h` | `--help` | 否 | 查看帮助 |

*SQLite 通常不需要用户名和密码。

### 推荐调用示例

以下命令都以 `@.opencode/skills/sql-tool/script/` 作为工作目录，且连接信息仅为占位示例：

```bash
./sql-tool.exe -u "jdbc:postgresql://<host>:<port>/<maintenance_db>" -user "<username>" -p "<password>" -d "drivers" -s "SELECT 1"
```

```bash
./sql-tool.exe -u "jdbc:postgresql://<host>:<port>/<maintenance_db>" -user "<username>" -p "<password>" -d "drivers" -s "CREATE DATABASE <new_database_name>"
```

```bash
./sql-tool.exe -u "jdbc:postgresql://<host>:<port>/<db_name>" -user "<username>" -p "<password>" -d "drivers" -s "SELECT current_database()"
```

### 帮助命令

```bash
./sql-tool.exe --help
```

## 6. 常见错误与处理

| 错误现象                       | 常见原因 | 处理方式                                                                    |
|----------------------------|---|-------------------------------------------------------------------------|
| 找不到 `sql-tool.exe`         | 文档写错路径，或从错误目录执行 | 只使用 `@.opencode/skills/sql-tool/script/sql-tool.exe`，并把工作目录设为 `script/` |
| `驱动目录不存在` / `驱动目录为空`       | 未在 `script/` 目录下执行，或 `drivers/` 中没有驱动 | 检查工作目录是否为 `@.opencode/skills/sql-tool/script/`，并确认 `drivers/` 下已有匹配 JAR |
| `No suitable driver found` | 驱动类型不匹配、JAR 缺失或损坏 | 对照 JDBC 前缀检查文件名；必要时重新下载匹配驱动或向用户寻求如何获取驱动                                 |
| 无法连接数据库                    | 地址、端口、网络或数据库服务异常 | 先确认 JDBC URL、数据库服务状态和目标端口                                               |
| 认证失败                       | 用户名或密码错误 | 核对凭据                                                                    |

## 7. 安全边界

1. 未经用户明确确认，不执行 `DROP DATABASE`、`DROP TABLE`、`TRUNCATE` 等破坏性操作。
2. 未经用户明确确认，不执行无 `WHERE` 条件的 `DELETE` 或 `UPDATE`。
3. 对于大结果集，只展示必要摘要和行数。

## 8. 实操建议

- 先做连通性验证，再做写操作。
- PostgreSQL 管理动作（如创建数据库）建议先连接 `postgres` 这样的维护库执行。
- 不确定表结构时，先查元数据或 `information_schema`。
- 只在当前仓库 live 目录中补驱动，不把驱动下载到系统临时目录或个人绝对路径。
