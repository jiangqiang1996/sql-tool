package top.jiangqiang.tools.management;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Provides database management operations (user management, permissions, etc.)
 */
public class DatabaseManagement {

    private final Connection connection;

    public DatabaseManagement(Connection connection) {
        this.connection = connection;
    }

    /**
     * Lists all users in the database
     * @return List of usernames
     * @throws SQLException if a database access error occurs
     */
    public List<String> listUsers() throws SQLException {
        List<String> users = new ArrayList<>();
        String url = connection.getMetaData().getURL();

        String query = getUsersQuery(url);
        if (query == null) {
            throw new SQLException("Listing users not supported for this database type");
        }

        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {
            while (rs.next()) {
                users.add(rs.getString(1));
            }
        }

        return users;
    }

    /**
     * Creates a new database user
     * @param username Username to create
     * @param password Password for the new user
     * @throws SQLException if a database access error occurs
     */
    public void createUser(String username, String password) throws SQLException {
        String url = connection.getMetaData().getURL();
        String createSql = getCreateUserSql(url, username, password);

        try (Statement stmt = connection.createStatement()) {
            stmt.execute(createSql);
        }
    }

    /**
     * Grants all privileges on a database to a user
     * @param username Username to grant privileges to
     * @param database Database name (can be null for all databases)
     * @throws SQLException if a database access error occurs
     */
    public void grantAllPrivileges(String username, String database) throws SQLException {
        String url = connection.getMetaData().getURL();
        String grantSql = getGrantAllSql(url, username, database);

        try (Statement stmt = connection.createStatement()) {
            stmt.execute(grantSql);
        }
    }

    /**
     * Drops a database user
     * @param username Username to drop
     * @throws SQLException if a database access error occurs
     */
    public void dropUser(String username) throws SQLException {
        String url = connection.getMetaData().getURL();
        String dropSql = getDropUserSql(url, username);

        try (Statement stmt = connection.createStatement()) {
            stmt.execute(dropSql);
        }
    }

    // --- Database-specific query generation ---

    private String getUsersQuery(String url) {
        if (url.startsWith("jdbc:mysql:") || url.startsWith("jdbc:mariadb:")) {
            return "SELECT User FROM mysql.user WHERE Host = '%' OR Host = 'localhost' ORDER BY User";
        } else if (url.startsWith("jdbc:postgresql:")) {
            return "SELECT usename FROM pg_user ORDER BY usename";
        } else if (url.startsWith("jdbc:sqlserver:")) {
            return "SELECT name FROM sys.sql_logins ORDER BY name";
        } else if (url.startsWith("jdbc:oracle:")) {
            return "SELECT username FROM all_users ORDER BY username";
        }
        return null;
    }

    private String getCreateUserSql(String url, String username, String password) {
        if (url.startsWith("jdbc:mysql:") || url.startsWith("jdbc:mariadb:")) {
            return String.format("CREATE USER '%s'@'%%' IDENTIFIED BY '%s';", username, password);
        } else if (url.startsWith("jdbc:postgresql:")) {
            return String.format("CREATE USER %s WITH PASSWORD '%s';", username, password);
        } else if (url.startsWith("jdbc:sqlserver:")) {
            return String.format("CREATE LOGIN %s WITH PASSWORD = '%s';", username, password);
        } else if (url.startsWith("jdbc:oracle:")) {
            return String.format("CREATE USER %s IDENTIFIED BY %s;", username, password);
        }
        throw new UnsupportedOperationException("Create user not supported for this database type");
    }

    private String getGrantAllSql(String url, String username, String database) {
        if (url.startsWith("jdbc:mysql:") || url.startsWith("jdbc:mariadb:")) {
            String db = database != null ? database : "*";
            return String.format("GRANT ALL PRIVILEGES ON %s.* TO '%s'@'%%'; FLUSH PRIVILEGES;", db, username);
        } else if (url.startsWith("jdbc:postgresql:")) {
            if (database != null) {
                return String.format("GRANT ALL PRIVILEGES ON DATABASE %s TO %s;", database, username);
            }
            return String.format("GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO %s;", username);
        } else if (url.startsWith("jdbc:sqlserver:")) {
            if (database != null) {
                return String.format("USE %s; GRANT ALL PRIVILEGES TO %s;", database, username);
            }
            return String.format("GRANT CONTROL SERVER TO %s;", username);
        } else if (url.startsWith("jdbc:oracle:")) {
            return String.format("GRANT ALL PRIVILEGES TO %s;", username);
        }
        throw new UnsupportedOperationException("Grant privileges not supported for this database type");
    }

    private String getDropUserSql(String url, String username) {
        if (url.startsWith("jdbc:mysql:") || url.startsWith("jdbc:mariadb:")) {
            return String.format("DROP USER '%s'@'%%';", username);
        } else if (url.startsWith("jdbc:postgresql:")) {
            return String.format("DROP USER %s;", username);
        } else if (url.startsWith("jdbc:sqlserver:")) {
            return String.format("DROP LOGIN %s;", username);
        } else if (url.startsWith("jdbc:oracle:")) {
            return String.format("DROP USER %s CASCADE;", username);
        }
        throw new UnsupportedOperationException("Drop user not supported for this database type");
    }
}