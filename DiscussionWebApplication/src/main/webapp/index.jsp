<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, repository.DBConnection" %>

<%
    // Handle login logic at the top
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    if (username != null && password != null) {
        if ("admin".equalsIgnoreCase(username) && "admin123".equals(password)) {
            // Hardcoded admin login
            session.setAttribute("username", "admin");
            session.setAttribute("fullName", "Administrator");
            response.sendRedirect("admin.jsp");
            return;
        } else {
            // Regular user login from DB with approval check
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "SELECT fullname, is_approved FROM users WHERE username = ? AND password = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, username);
                ps.setString(2, password); // NOTE: Use hashing in production
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    boolean isApproved = rs.getBoolean("is_approved");
                    if (!isApproved) {
                        request.setAttribute("errorMessage", "Your account is awaiting admin approval.");
                    } else {
                        session.setAttribute("username", username);
                        session.setAttribute("fullName", rs.getString("fullname"));
                        response.sendRedirect("dashboard.jsp");
                        return;
                    }
                } else {
                    request.setAttribute("errorMessage", "Invalid username or password.");
                }

                rs.close();
                ps.close();
            } catch (SQLException e) {
                request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Login Page</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>
    <h2>Login</h2>

    <form method="post" action="index.jsp">
        Username: <input type="text" name="username" required><br><br>
        Password: <input type="password" name="password" required><br><br>
        <input type="submit" value="Login">
    </form>

    <% if (request.getAttribute("errorMessage") != null) { %>
        <p style="color:red;"><%= request.getAttribute("errorMessage") %></p>
    <% } %>

    <p>
        <a href="register.jsp">New user? Register here</a><br>
        <a href="forget_password.jsp">Forgot Password?</a>
    </p>
</body>
</html>
