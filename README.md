# SQL Tool - 对 AI 友好的命令行数据库操作工具

一个功能强大的命令行工具，支持动态加载驱动、格式化输出和数据库管理能力，让 AI 能够轻松操作任意数据库。

## 功能特性

- **动态驱动加载**：将任意 JDBC 驱动放入 `drivers` 目录，工具会自动加载
- **支持任意数据库**：适用于任何提供 JDBC 驱动的数据库
- **支持任意 SQL**：执行查询、DML、DDL 和数据库管理命令
- **格式化输出**：结果以清晰的 ASCII 表格展示，便于 AI 解析
- **数据库管理**：内置用户管理支持（创建、列出、删除用户，授权权限）
- **jpackage 打包**：为你的平台生成原生二进制可执行文件
- **GraalVM 原生编译**：默认包含五大主流数据库驱动，可直接运行无需 Java

## 支持的数据库

### 内置原生驱动（GraalVM 原生编译默认包含）

| 数据库 | 驱动版本 | 内置用户管理 |
|--------|----------|--------------|
| MySQL/MariaDB | 8.0.33 | ✅ 支持 |
| PostgreSQL | 42.6.0 | ✅ 支持 |
| SQL Server | 9.4.1 | ✅ 支持 |
| Oracle | 21.13.0 | ✅ 支持 |
| SQLite | 3.42.0 | ⚠️ 无用户系统 |

> **说明**：对于国产数据库如 OceanBase、达梦、PolarDB 等，只要提供 JDBC 驱动，放入 `drivers` 目录即可通过通用 JDBC 连接使用。但目前没有内置特定的用户管理 SQL 支持。

## 环境要求

- Java 17+
- Maven 3.6+
- 对于 jpackage：包含 jpackage 工具的 JDK（JDK 16+ 通常已包含）
- 对于 GraalVM 原生编译：GraalVM JDK 17+

## 快速开始

### 从源码构建

```bash
git clone <repository-url>
cd sql-tool
mvn clean package
```

### 创建原生二进制文件

**使用 jpackage（需要 JDK）：**
```bash
mvn package jpackage:jpackage
```

原生可执行文件将生成在 `target/dist/` 目录。

**使用 GraalVM Native Image（standalone 可执行文件，无需 JRE）：**
```bash
mvn clean -Pnative native:compile
```

完成后可执行文件在 `target/sqltool`（或 `target/sqltool.exe`）。

### 添加 JDBC 驱动

**JAR 包方式运行：** 将你的 JDBC 驱动 JAR 文件放入 `drivers` 目录。常用驱动：

| 数据库 | 下载 | 连接 URL 示例 |
|----------|----------|-------------|
| MySQL/MariaDB | [MySQL Connector](https://dev.mysql.com/downloads/connector/j/) | `jdbc:mysql://localhost:3306/dbname` |
| PostgreSQL | [PostgreSQL JDBC](https://jdbc.postgresql.org/download.html) | `jdbc:postgresql://localhost:5432/dbname` |
| SQL Server | [MS JDBC Driver](https://learn.microsoft.com/zh-cn/sql/connect/jdbc/download-microsoft-jdbc-driver-for-sql-server) | `jdbc:sqlserver://localhost:1433;databaseName=dbname` |
| Oracle | [Oracle JDBC](https://www.oracle.com/database/technologies/appdev/jdbc-downloads.html) | `jdbc:oracle:thin:@localhost:1521:ORCL` |
| SQLite | [SQLite JDBC](https://github.com/xerial/sqlite-jdbc) | `jdbc:sqlite:database.db` |

**GraalVM 原生编译运行：** 五大主流数据库驱动已内置，无需额外驱动。

## 使用方法

### 基本查询

```bash
# 使用 java -jar 运行
java -jar target/sql-tool-1.0.0.jar --url <jdbc-url> --username <user> --password <pass> --sql "SELECT * FROM table_name"

# 使用原生可执行文件（jpackage 或 GraalVM 构建后）
sqltool --url <jdbc-url> --username <user> --password <pass> --sql "SELECT * FROM table_name"
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
  sqltool --url jdbc:mysql://localhost:3306/mydb --username root --password secret --sql "SELECT * FROM users"
  sqltool --url jdbc:postgresql://localhost:5432/mydb -user postgres -p postgres -s "CREATE TABLE test (id INT, name VARCHAR(255))"
```

### 使用示例

**查询数据：**
```bash
sqltool --url jdbc:mysql://localhost:3306/mydb --username root --password secret --sql "SELECT * FROM users"
```

**创建表：**
```bash
sqltool --url jdbc:postgresql://localhost:5432/mydb -user postgres -p secret -s "CREATE TABLE employees (id SERIAL PRIMARY KEY, name VARCHAR(100), salary DECIMAL(10,2))"
```

**插入数据：**
```bash
sqltool --url jdbc:mysql://localhost:3306/mydb --username root --password secret --sql "INSERT INTO users (name, email) VALUES ('张三', 'zhangsan@example.com')"
```

**简写形式：**
```bash
sqltool -u jdbc:sqlite:mydb.db -s "SELECT * FROM users"
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

1. **动态类加载**：JDBC 驱动在运行时通过自定义 URLClassLoader 从 drivers 目录加载。这允许添加新驱动而无需重新构建工具（仅适用于 JAR 模式运行）。

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
AI：调用：sqltool --url jdbc:mysql://localhost:3306/mysql --username root --password secret --sql "SELECT * FROM user"
AI：读取格式化输出并将信息呈现给用户
```

## 构建不同包类型

jpackage 自动检测你的平台并创建相应的包格式：

- Windows: `.exe` 安装程序 或 `.msi`
- macOS: `.dmg` 或 `.pkg`
- Linux: `.deb` 或 `.rpm`

输出始终在 `target/dist/` 目录。

## 使用 GraalVM Native Image 构建

SQL Tool 可以使用 GraalVM Native Image 编译为独立的原生可执行文件。这消除了对 Java 运行时的依赖，并生成小巧快速的可执行文件。

> **重要说明**：原生镜像编译要求**在构建时包含所有 JDBC 驱动**（GraalVM Native Image 不支持在运行时从外部 JAR 加载新类）。本构建默认包含 5 个流行数据库驱动。

### 前置条件

1. **安装 GraalVM JDK 17+**
   - 从 [Oracle GraalVM](https://www.oracle.com/java/technologies/downloads/#graalvm) 或 [GraalVM Community](https://github.com/graalvm/graalvm-ce-builds) 下载
   - 将 `JAVA_HOME` 设置为你的 GraalVM 安装目录
   - 将 `%JAVA_HOME%\bin` 添加到 `PATH`（Windows）

2. **安装 Visual Studio Build Tools（仅 Windows）**
   - 下载 [Build Tools for Visual Studio 2022](https://visualstudio.microsoft.com/zh-hans/downloads/#build-tools-for-visual-studio-2022)
   - 安装 **"使用 C++ 的桌面开发"** 工作负载
   - 这提供了原生链接所需的 `cl.exe` C/C++ 编译器

3. **Maven 3.6+**
   - 大多数环境已配置完成

### 编译步骤

```cmd
# 1. 克隆或下载源码
git clone <repository-url>
cd sql-tool

# 2. 清理并编译为原生可执行文件
mvn clean -Pnative native:compile
```

这个过程根据你的机器需要 2-5 分钟。完成后，你会在 `target/sqltool.exe` 找到原生可执行文件。

### 编译结果

- **文件大小**：~13 MB（压缩后，无需外部依赖）
- **包含驱动**：MySQL 8.0, PostgreSQL 42.6, SQLite 3.42, SQL Server 9.4, Oracle 21.13
- **无需 JRE**：可执行文件可以直接在 Windows/macOS/Linux 上运行，无需安装 Java

### 测试可执行文件

```cmd
target\sqltool.exe --help
```

### 已知警告

在编译过程中，你可能会看到一些无害的警告：

- `Properties file ... does not match the recommended layout`：来自 Oracle JDBC 驱动 - 不影响功能
- `Feature ... is annotated with @AutomaticFeature deprecated`：来自 Oracle JDBC 驱动 - 我们的配置已经修复，警告来自原始类注解
- `The URL protocol jar is not tested`：GraalVM 信息性警告 - 不影响功能

这些警告不会阻止编译或影响运行时。

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
