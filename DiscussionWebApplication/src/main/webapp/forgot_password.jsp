<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, repository.DBConnection" %>

<%
    String message = "";
    String error = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String usernameOrEmail = request.getParameter("usernameOrEmail");

        if (usernameOrEmail == null || usernameOrEmail.trim().isEmpty()) {
            error = "Please enter your username or email.";
        } else {
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "SELECT username, email FROM users WHERE username = ? OR email = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, usernameOrEmail);
                ps.setString(2, usernameOrEmail);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    // TODO: Generate reset token and send email
                    // For demo, just display message
                    message = "If an account exists with the provided username/email, " +
                              "a password reset link has been sent to the registered email.";
                } else {
                    error = "No account found with that username or email.";
                }

                rs.close();
                ps.close();
            } catch (Exception e) {
                error = "Database error: " + e.getMessage();
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Forgot Password</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>
    <h2>Forgot Password</h2>

    <% if (!message.isEmpty()) { %>
        <p style="color:green;"><%= message %></p>
        <p><a href="index.jsp">Back to Login</a></p>
    <% } else { %>

        <% if (!error.isEmpty()) { %>
            <p style="color:red;"><%= error %></p>
        <% } %>

        <form method="post" action="forgot_password.jsp">
            <label for="usernameOrEmail">Username or Email:</label><br>
            <input type="text" id="usernameOrEmail" name="usernameOrEmail" required><br><br>
            <button type="submit">Send Password Reset Link</button>
        </form>

        <p><a href="index.jsp">Back to Login</a></p>
    <% } %>
</body>
</html>
