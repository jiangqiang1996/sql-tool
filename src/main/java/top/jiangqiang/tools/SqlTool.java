package top.jiangqiang.tools;

import top.jiangqiang.tools.cli.CommandLineArgs;
import top.jiangqiang.tools.connection.DriverLoader;
import top.jiangqiang.tools.execution.SqlExecutor;
import top.jiangqiang.tools.formatting.ResultFormatter;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Main entry point for SQL Tool command-line application
 */
public class SqlTool {

    public static void main(String[] args) {
        CommandLineArgs cliArgs = new CommandLineArgs(args);

        if (!cliArgs.isValid()) {
            cliArgs.printHelp();
            System.exit(1);
        }

        try {
            // Load drivers from drivers directory
            DriverLoader driverLoader = new DriverLoader(cliArgs.getDriversDir());
            driverLoader.loadDrivers();

            // Get connection
            Connection connection = cliArgs.createConnection();
            System.out.println("Connected successfully to: " + cliArgs.getUrl());

            // Execute SQL
            String sql = cliArgs.getSql();
            if (sql == null || sql.isEmpty()) {
                System.err.println("No SQL provided to execute");
                System.exit(1);
                return;
            }

            SqlExecutor executor = new SqlExecutor(connection);
            boolean isResultSet = executor.execute(sql);

            if (isResultSet) {
                ResultSet resultSet = executor.getResultSet();
                ResultFormatter formatter = new ResultFormatter();
                formatter.format(resultSet, System.out);
                resultSet.close();
            } else {
                int updateCount = executor.getUpdateCount();
                System.out.printf("Query executed successfully. Rows affected: %d%n", updateCount);
            }

            // Cleanup
            executor.close();
            connection.close();
            System.out.println("\nDisconnected from database");

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}