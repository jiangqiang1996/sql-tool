package top.jiangqiang.tools;

import top.jiangqiang.tools.cli.CommandLineArgs;
import top.jiangqiang.tools.connection.DriverLoader;
import top.jiangqiang.tools.execution.SqlExecutor;
import top.jiangqiang.tools.formatting.ResultFormatter;

import java.sql.Connection;

/**
 * SQL Tool 命令行应用主入口。
 * 通过动态加载 JDBC 驱动，连接任意数据库并执行 SQL 语句。
 */
public class SqlTool {

    public static void main(String[] args) {
        CommandLineArgs cliArgs = new CommandLineArgs(args);

        if (!cliArgs.isValid()) {
            cliArgs.printHelp();
            System.exit(1);
        }

        try {
            DriverLoader driverLoader = new DriverLoader(cliArgs.getDriversDir());
            driverLoader.loadDrivers();

            try (Connection connection = cliArgs.createConnection()) {
                System.out.println("Connected successfully to: " + cliArgs.getUrl());

                String sql = cliArgs.getSql();
                if (sql == null || sql.isEmpty()) {
                    System.err.println("No SQL provided to execute");
                    System.exit(1);
                    return;
                }

                try (SqlExecutor executor = new SqlExecutor(connection)) {
                    boolean isResultSet = executor.execute(sql);

                    if (isResultSet) {
                        ResultFormatter formatter = new ResultFormatter();
                        formatter.format(executor.getResultSet(), System.out);
                    } else {
                        int updateCount = executor.getUpdateCount();
                        System.out.printf("Query executed successfully. Rows affected: %d%n", updateCount);
                    }
                }
            }

            System.out.println("\nDisconnected from database");

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            if (Boolean.getBoolean("sql-tool.debug")) {
                e.printStackTrace();
            }
            System.exit(1);
        }
    }
}