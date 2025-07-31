package database;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/your_database_name";
    private static final String JDBC_USER = "your_username";
    private static final String JDBC_PASSWORD = "your_password";

    // Load the JDBC driver
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver"); // for MySQL 8+
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    // Get a connection
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
    }
}
