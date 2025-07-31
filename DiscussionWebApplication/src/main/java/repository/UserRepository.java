package repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import entity.User;

public class UserRepository {

    public boolean registerUser(User user) {
        boolean success = false;

        // Insert all relevant fields including mobile_number and batch_code
        String sql = "INSERT INTO users (fullname, username, email, mobile_number, batch_code, password) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, user.getFullName());
            stmt.setString(2, user.getUsername());
            stmt.setString(3, user.getEmail());
            stmt.setString(4, user.getMobNumber());
            stmt.setString(5, user.getBatchCode());
            stmt.setString(6, user.getPassword()); // Note: hash password in production

            int rowsInserted = stmt.executeUpdate();
            success = rowsInserted > 0;

        } catch (SQLException e) {
            e.printStackTrace();  // Ideally, use a logger
        }

        return success;
    }
}
