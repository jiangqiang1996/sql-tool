# SQL Tool - 对 AI 友好的命令行数据库操作工具

一个轻量级命令行工具，通过动态加载 JDBC 驱动连接任意数据库，执行 SQL 语句并以 ASCII 表格格式化输出结果。专为 AI 工具链（如 OpenCode Skills）设计，让 AI 能够直接操作数据库。

## 功能特性

- **动态驱动加载**：将任意 JDBC 驱动 JAR 放入 `drivers` 目录即可自动发现和加载（优先读取 SPI 配置）
- **支持任意数据库**：适用于所有提供 JDBC 驱动的数据库（MySQL、PostgreSQL、SQL Server、Oracle、SQLite、达梦、人大金仓等）
- **支持任意 SQL**：执行查询（SELECT）、DML（INSERT/UPDATE/DELETE）、DDL（CREATE/ALTER/DROP）等全部 SQL 类型
- **格式化输出**：查询结果以清晰的 ASCII 表格展示，非查询语句显示影响行数
- **零外部依赖**：纯 JDK 实现，仅依赖 `java.base`、`java.sql`、`java.naming` 模块

## 支持的数据库

对于任意数据库，只要提供 JDBC 驱动 JAR 文件，放入 `drivers` 目录即可使用。`.opencode/skills/sql-tool/SKILL.md` 中的 AI 技能可自动下载对应驱动：

> **说明**：对于国产数据库如 OceanBase、达梦、PolarDB 等，AI 可能无法自动下载驱动，只需你告诉 AI 驱动路径或者直接放入 `drivers` 目录即可。

### JDBC URL 与驱动匹配

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

### 从源码构建

- Java 17+
- Maven 3.6+

### 仅使用（不构建）

如果无需基于源码构建，直接复制项目根目录下的 `.opencode` 目录到自己项目即可。

## 从源码构建

运行项目根目录下的 `build.bat`：

```bat
build.bat
```

构建过程会依次执行：Maven 打包 → jpackage 生成原生镜像 → 裁剪运行时 → 复制到 `.opencode/skills/sql-tool/script/` 目录。

构建完成后，可执行文件位于 `target/jpackage-output/sql-tool/sql-tool.exe`，同时会自动同步到 `.opencode/skills/sql-tool/script/`。

## 集成到 AI 工具链

将项目根目录下的 `.opencode/skills` 复制到自己项目的 `.opencode/skills` 目录（或全局配置目录），即可让你的 AI 拥有操作数据库的能力。

## 快速开始

### 1. 检查驱动

进入 `sql-tool` 脚本目录：

```bat
cd .opencode\skills\sql-tool\script
```

检查 `drivers` 目录下是否已有对应数据库的驱动 JAR 文件。如果没有，先下载驱动到 `drivers` 目录：

```powershell
# 示例：下载 PostgreSQL 驱动
cd drivers
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.5/postgresql-42.7.5.jar' -OutFile 'postgresql.jar'"
cd ..
```

### 2. 测试连接

```bat
sql-tool.exe -u "jdbc:postgresql://localhost:5432/postgres" -user "postgres" -p "password" -d "drivers" -s "SELECT 1"
```

连接成功后会输出 `Connected successfully to: ...` 和查询结果。

## 使用示例

所有示例都假设工作目录为 `.opencode/skills/sql-tool/script/`。

### 查询数据

```bat
:: MySQL 查询
sql-tool.exe -u "jdbc:mysql://localhost:3306/mydb" -user "root" -p "password" -d "drivers" -s "SELECT * FROM users LIMIT 10"

:: SQLite（不需要用户名密码）
sql-tool.exe -u "jdbc:sqlite:./mydb.db" -d "drivers" -s "SELECT name FROM sqlite_master WHERE type='table'"
```

### 创建表

```bat
sql-tool.exe -u "jdbc:postgresql://localhost:5432/mydb" -user "postgres" -p "password" -d "drivers" -s "CREATE TABLE users (id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL, email VARCHAR(100) UNIQUE NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)"
```

### 插入数据

```bat
sql-tool.exe -u "jdbc:mysql://localhost:3306/mydb" -user "root" -p "password" -d "drivers" -s "INSERT INTO users (name, email) VALUES ('zhangsan', 'zhangsan@example.com')"
```

### 创建数据库

```bat
:: PostgreSQL 需要先连接到维护库（如 postgres）
sql-tool.exe -u "jdbc:postgresql://localhost:5432/postgres" -user "postgres" -p "password" -d "drivers" -s "CREATE DATABASE mynewdb"
```

### 查看帮助

```bat
sql-tool.exe --help
```

## 参数说明

| 短参数 | 长参数 | 必填 | 说明 |
|---|---|---|---|
| `-u` | `--url` | 是 | JDBC 连接地址 |
| `-user` | `--username` | 否* | 数据库用户名 |
| `-p` | `--password` | 否* | 数据库密码 |
| `-s` | `--sql` | 是 | 要执行的 SQL |
| `-d` | `--drivers-dir` | 否 | 驱动目录（默认为可执行文件同级 `drivers` 目录） |
| `-h` | `--help` | 否 | 查看帮助 |

\* SQLite 等嵌入式数据库通常不需要用户名和密码。

## 项目结构

```
sql-tool/
├── src/main/java/top/jiangqiang/tools/
│   ├── SqlTool.java              # 主入口
│   ├── cli/
│   │   └── CommandLineArgs.java  # 命令行参数解析
│   ├── connection/
│   │   └── DriverLoader.java     # 动态 JDBC 驱动加载（SPI 优先）
│   ├── execution/
│   │   └── SqlExecutor.java      # SQL 执行器
│   ├── formatting/
│   │   └── ResultFormatter.java  # ASCII 表格格式化输出
│   └── management/
│       └── DatabaseManagement.java # 数据库管理工具类（预留）
├── src/main/resources/drivers/
│   └── README.md                  # 驱动目录说明
├── build.bat                      # 构建脚本
├── docker-compose.yml             # 测试用数据库环境
├── pom.xml                        # Maven 项目配置
└── .opencode/skills/sql-tool/     # AI Skill 集成
    ├── SKILL.md                   # AI 技能描述与规范
    └── script/                    # 构建产物输出目录
```

## 测试

项目提供了针对不同数据库的测试脚本：

| 脚本 | 说明 |
|---|---|
| `test-h2.bat` | H2 内存数据库测试（无需外部依赖） |
| `test-mysql.bat` | MySQL 测试（需要 MySQL 服务） |
| `test-postgres.bat` | PostgreSQL 测试（需要 PostgreSQL 服务） |
| `test-all.bat` | 运行全部测试 |

可通过 `docker-compose up -d` 启动 MySQL 和 PostgreSQL 测试环境。

## 常见问题（FAQ）

### Q: 提示 "No suitable driver found" 是什么原因？

A: 这通常是以下原因之一：

- 驱动 JAR 文件不存在于 `drivers` 目录
- 驱动类型与 JDBC URL 不匹配
- 驱动 JAR 文件损坏

解决方法：对照上方 **JDBC URL 与驱动匹配** 表，确认 `drivers` 目录中有正确的驱动文件。

### Q: 提示 "找不到 sql-tool.exe" 怎么办？

A: 你需要从正确的目录执行命令。`sql-tool.exe` 始终位于 `.opencode/skills/sql-tool/script/` 目录下。执行前请先进入该目录：

```bat
cd .opencode\skills\sql-tool\script
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

### Q: 如何查看详细错误信息？

A: 默认情况下只输出错误摘要。如需完整堆栈信息，启动时添加 JVM 参数：

```bat
sql-tool.exe -J-Dsql-tool.debug=true -u "..." -s "..."
```

## 安全约定

1. 未经你明确确认，AI 不会执行 `DROP DATABASE`、`DROP TABLE`、`TRUNCATE` 等破坏性操作
2. 未经你明确确认，AI 不会执行无 `WHERE` 条件的 `DELETE` 或 `UPDATE`
3. 对于大结果集，只会展示必要摘要和行数

## 实操建议

- 先做连通性验证（`SELECT 1`），再做写操作
- PostgreSQL 管理动作（如创建数据库）建议先连接 `postgres` 这样的维护库执行
- 不确定表结构时，先查元数据或 `information_schema`
- 只在当前仓库的 `.opencode/skills/sql-tool/script/drivers/` 目录存放驱动

## 许可证

[Apache License 2.0](LICENSE)
