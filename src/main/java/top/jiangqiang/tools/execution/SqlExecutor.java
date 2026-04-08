package top.jiangqiang.tools.execution;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * 执行 SQL 语句并管理 Statement/ResultSet 生命周期。
 * <p>
 * 使用完毕后应调用 {@link #close()} 或配合 try-with-resources 释放资源。
 * 关闭时会同时关闭内部持有的 ResultSet 和 Statement，但不关闭 Connection。
 */
public class SqlExecutor implements AutoCloseable {

    private final Connection connection;
    private Statement statement;
    private ResultSet resultSet;
    private int updateCount;

    public SqlExecutor(Connection connection) {
        this.connection = connection;
    }

    /**
     * Executes the given SQL statement
     * @return true if the execution returned a result set, false if it returned an update count
     * @throws SQLException if a database access error occurs
     */
    public boolean execute(String sql) throws SQLException {
        statement = connection.createStatement();
        boolean hasResultSet = statement.execute(sql);

        if (hasResultSet) {
            resultSet = statement.getResultSet();
        } else {
            updateCount = statement.getUpdateCount();
        }

        return hasResultSet;
    }

    public ResultSet getResultSet() {
        return resultSet;
    }

    public int getUpdateCount() {
        return updateCount;
    }

    @Override
    public void close() throws SQLException {
        if (resultSet != null) {
            resultSet.close();
        }
        if (statement != null) {
            statement.close();
        }
    }
}