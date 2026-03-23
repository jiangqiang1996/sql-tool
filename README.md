# SQL Tool - AI-friendly Command-line Database Operations

A versatile command-line tool that enables AI to operate any database with dynamic driver loading, formatted output, and database management capabilities.

## Features

- **Dynamic Driver Loading**: Place any JDBC driver in the `drivers` directory and the tool automatically loads it
- **Support Any Database**: Works with any database that provides a JDBC driver
- **Support Any SQL**: Execute queries, DML, DDL, and database management commands
- **Formatted Output**: Results displayed as clean ASCII tables for easy AI parsing
- **Database Management**: Built-in support for user management (create, list, drop users, grant privileges)
- **jpackage Packaging**: Creates native binary executables for your platform

## Requirements

- Java 17+
- Maven 3.6+
- For jpackage: JDK with jpackage tool (usually included in JDK 16+)

## Quick Start

### Build from source

```bash
git clone <repository-url>
cd sql-tool
mvn clean package
```

### Create native binary with jpackage

```bash
mvn package jpackage:jpackage
```

The native executable will be created in `target/dist/` directory.

### Add your JDBC driver

Place your JDBC driver JAR file into the `drivers` directory. Common drivers:

| Database | Download | Example URL |
|----------|----------|-------------|
| MySQL/MariaDB | [MySQL Connector](https://dev.mysql.com/downloads/connector/j/) | `jdbc:mysql://localhost:3306/dbname` |
| PostgreSQL | [PostgreSQL JDBC](https://jdbc.postgresql.org/download.html) | `jdbc:postgresql://localhost:5432/dbname` |
| SQL Server | [MS JDBC Driver](https://learn.microsoft.com/en-us/sql/connect/jdbc/download-microsoft-jdbc-driver-for-sql-server) | `jdbc:sqlserver://localhost:1433;databaseName=dbname` |
| Oracle | [Oracle JDBC](https://www.oracle.com/database/technologies/appdev/jdbc-downloads.html) | `jdbc:oracle:thin:@localhost:1521:ORCL` |
| SQLite | [SQLite JDBC](https://github.com/xerial/sqlite-jdbc) | `jdbc:sqlite:database.db` |

## Usage

### Basic Query

```bash
# Using java -jar
java -jar target/sql-tool-1.0.0.jar --url <jdbc-url> --username <user> --password <pass> --sql "SELECT * FROM table_name"

# Using native executable (after jpackage)
sqltool --url <jdbc-url> --username <user> --password <pass> --sql "SELECT * FROM table_name"
```

### Command Line Options

```
Usage: sqltool [options] --url <jdbc-url> --sql <query>

Options:
  -u, --url <jdbc-url>       JDBC connection URL (required)
  -user, --username <user>   Database username
  -p, --password <pass>      Database password
  -s, --sql <query>          SQL to execute (required)
  -d, --drivers-dir <path>   Directory containing JDBC drivers (default: ./drivers)
  -h, --help                 Show this help message
```

### Examples

**Query data:**
```bash
sqltool --url jdbc:mysql://localhost:3306/mydb --username root --password secret --sql "SELECT * FROM users"
```

**Create table:**
```bash
sqltool --url jdbc:postgresql://localhost:5432/mydb -user postgres -p secret -s "CREATE TABLE employees (id SERIAL PRIMARY KEY, name VARCHAR(100), salary DECIMAL(10,2))"
```

**Insert data:**
```bash
sqltool --url jdbc:mysql://localhost:3306/mydb --username root --password secret --sql "INSERT INTO users (name, email) VALUES ('John Doe', 'john@example.com')"
```

**Short form:**
```bash
sqltool -u jdbc:sqlite:mydb.db -s "SELECT * FROM users"
```

## Output Format

Query results are formatted as ASCII tables for easy reading and parsing:

```
Connected successfully to: jdbc:mysql://localhost:3306/mydb
Loading 1 driver(s) from drivers...
  Loading: mysql-connector-java-8.0.30.jar
    Found driver: com.mysql.cj.jdbc.Driver (com.mysql.cj.jdbc.Driver)
Loaded 1 driver(s) successfully
+----+----------+---------------------+
| id | name     | email               |
+----+----------+---------------------+
| 1  | John Doe | john@example.com    |
| 2  | Jane Doe | jane@example.com    |
+----+----------+---------------------+
2 row(s) returned

Disconnected from database
```

Non-query operations (INSERT, UPDATE, CREATE, etc.) show rows affected:

```
Query executed successfully. Rows affected: 1
```

## Database Management

While you can execute any SQL directly, SQL Tool also has built-in database management capabilities for common operations. To use these, you can invoke the management methods via your own wrapper scripts or extend the CLI as needed.

Supported operations for major databases:

- **List Users**: Get all database users
- **Create User**: Create a new database user with password
- **Grant Privileges**: Grant all privileges to a user on a database
- **Drop User**: Remove a database user

The management API is database-aware and generates the correct SQL for:
- MySQL / MariaDB
- PostgreSQL
- SQL Server
- Oracle

## Architecture

```
sql-tool/
├── drivers/                    # External JDBC drivers directory
│   └── README.md
├── src/main/java/io/sqltool/
│   ├── SqlTool.java            # Main entry point
│   ├── cli/
│   │   └── CommandLineArgs.java    # CLI argument parsing
│   ├── connection/
│   │   ├── ConnectionConfig.java  # Connection configuration
│   │   └── DriverLoader.java      # Dynamic driver loading from disk
│   ├── execution/
│   │   └── SqlExecutor.java       # SQL execution handling
│   ├── formatting/
│   │   └── ResultFormatter.java   # ASCII table formatting
│   └── management/
│       └── DatabaseManagement.java # Database-specific management
└── pom.xml
```

### Key Design Points

1. **Dynamic Class Loading**: JDBC drivers are loaded from the drivers directory at runtime using a custom URLClassLoader. This allows adding new drivers without rebuilding the tool.

2. **Driver Shim**: A wrapper layer makes dynamically loaded drivers compatible with JDBC DriverManager.

3. **Any SQL Support**: The tool doesn't restrict what SQL you can execute - pass any valid SQL statement to the database.

4. **Formatting**: Results are formatted as ASCII tables that are both human-readable and easily parseable by AI systems.

## AI Integration

This tool is specifically designed to be used by AI agents. The structured output format makes it easy for AI to:
- Understand query results
- Verify operations completed successfully
- Extract data from database tables
- Perform database administration through natural language

Example AI interaction:
```
User: Show me all users in the local MySQL database
AI: Invokes: sqltool --url jdbc:mysql://localhost:3306/mysql --username root --password secret --sql "SELECT * FROM user"
AI: Reads the formatted output and presents information to the user
```

## Building Different Package Types

jpackage automatically detects your platform and creates the appropriate package format:

- Windows: `.exe` installer or `.msi`
- macOS: `.dmg` or `.pkg`
- Linux: `.deb` or `.rpm`

The output is always in `target/dist/`.

## Troubleshooting

### "No JAR files found in drivers"
- Make sure you have placed a JDBC driver JAR in the `drivers` directory
- Check that the file extension is `.jar` (case-insensitive)

### "Cannot load driver class"
- The driver JAR may be missing dependencies
- Make sure you have the correct driver JAR for your database version
- Check that the driver supports your Java version

### "No suitable driver found for jdbc:..."
- Check that the JDBC URL format matches what your driver expects
- Ensure the driver JAR contains a `java.sql.Driver` implementation
- Verify the driver JAR is actually in the drivers directory

## License

MIT License - feel free to use this project for any purpose.
