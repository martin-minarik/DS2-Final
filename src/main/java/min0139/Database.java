package min0139;

import java.sql.*;

public class Database {
    private Connection connection;

//    public static final String DB_CONNECTION_URL = "jdbc:oracle:thin:@<address>:oracle";
    public static final String DB_CONNECTION_URL = "";
    public static final String DB_CONNECTION_LOGIN = "";
    public static final String DB_CONNECTION_PASSWORD = "";

    public boolean connect() {
        return this.connect(DB_CONNECTION_URL,
                DB_CONNECTION_LOGIN,
                DB_CONNECTION_PASSWORD);
    }

    public boolean connect(String url, String login, String password) {
        try {
            connection = DriverManager.getConnection(url, login, password);
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }

        return true;
    }

    public boolean isConnected()
    {
        try
        {
            return connection != null && !connection.isClosed();
        } catch (SQLException e)
        {
            throw new RuntimeException(e);
        }
    }

    public void close() {
        try {
            connection.close();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public PreparedStatement createPreparedStatement(String sql) throws SQLException {
        return connection.prepareStatement(sql);
    }

    public CallableStatement createCallableStatement(String sql) throws SQLException {
        return connection.prepareCall(sql);
    }

    public ResultSet select(PreparedStatement statement) throws SQLException {
        return statement.executeQuery();
    }

    public int ExecuteNonQuery(PreparedStatement statement) throws SQLException
    {
        return statement.executeUpdate();
    }

}
