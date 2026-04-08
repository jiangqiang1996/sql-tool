package top.jiangqiang.tools.cli;

import java.io.File;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * 命令行参数解析器，处理 JDBC 连接参数与 SQL 语句。
 */
public class CommandLineArgs {

    private String url;
    private String username;
    private String password;
    private String sql;
    private String driversDir;
    private boolean valid = false;

    public CommandLineArgs(String[] args) {
        String appHome = System.getProperty("app.home", "");
        if (appHome.isEmpty()) {
            appHome = System.getProperty("user.dir");
        }
        this.driversDir = appHome + File.separator + "drivers";
        parse(args);
    }

    private void parse(String[] args) {
        if (args.length < 2) {
            validate();
            return;
        }

        for (int i = 0; i < args.length; i++) {
            String arg = args[i];
            switch (arg) {
                case "--url":
                case "-u":
                    if (i + 1 < args.length) url = args[++i];
                    break;
                case "--username":
                case "-user":
                    if (i + 1 < args.length) username = args[++i];
                    break;
                case "--password":
                case "-p":
                    if (i + 1 < args.length) password = args[++i];
                    break;
                case "--sql":
                case "-s":
                    if (i + 1 < args.length) sql = args[++i];
                    break;
                case "--drivers-dir":
                case "-d":
                    if (i + 1 < args.length) driversDir = args[++i];
                    break;
                case "--help":
                case "-h":
                    printHelp();
                    System.exit(0);
                    break;
                default:
                    // 最后一个非选项参数视为 SQL（便捷写法）
                    if (url != null && sql == null && i == args.length - 1) {
                        sql = arg;
                    }
                    break;
            }
        }

        validate();
    }

    private void validate() {
        valid = url != null && !url.isEmpty() && sql != null && !sql.isEmpty();
    }

    public boolean isValid() {
        return valid;
    }

    public String getUrl() {
        return url;
    }

    public String getUsername() {
        return username;
    }

    public String getPassword() {
        return password;
    }

    public String getSql() {
        return sql;
    }

    public String getDriversDir() {
        return driversDir;
    }

    public Connection createConnection() throws SQLException {
        if (username != null && password != null) {
            return DriverManager.getConnection(url, username, password);
        } else if (username != null) {
            return DriverManager.getConnection(url, username, "");
        } else {
            return DriverManager.getConnection(url);
        }
    }

    public void printHelp() {
        System.out.println("SQL Tool - Command Line Usage");
        System.out.println();
        System.out.println("Usage: sql-tool [options] -u <jdbc-url> -s <query>");
        System.out.println();
        System.out.println("Options:");
        System.out.println("  -u, --url <jdbc-url>       JDBC connection URL (required)");
        System.out.println("  -user, --username <user>   Database username");
        System.out.println("  -p, --password <pass>      Database password");
        System.out.println("  -s, --sql <query>          SQL to execute (required)");
        System.out.println("  -d, --drivers-dir <path>   Directory containing JDBC drivers (default: ./drivers)");
        System.out.println("  -h, --help                 Show this help message");
        System.out.println();
        System.out.println("Examples:");
        System.out.println("  sql-tool -u jdbc:mysql://localhost:3306/mydb -user root -p secret -s \"SELECT * FROM users\"");
        System.out.println("  sql-tool -u jdbc:postgresql://localhost:5432/mydb -user postgres -p postgres -s \"CREATE TABLE test (id INT)\"");
        System.out.println();
    }
}