<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, repository.DBConnection" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Record attendance when joinMeet is triggered
    if ("true".equals(request.getParameter("joinMeet"))) {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO meet_attendance (username) VALUES (?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.executeUpdate();
            ps.close();

            // Fetch latest Meet link from admin_settings
            String meetLink = "https://meet.google.com/"; // default fallback
            sql = "SELECT meet_link FROM admin_settings ORDER BY upload_date DESC LIMIT 1";
            ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                meetLink = rs.getString("meet_link");
            }
            rs.close();
            ps.close();

            // Redirect to Google Meet after saving attendance
            response.sendRedirect(meetLink);
            return;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Check if user has PDF permission
    boolean canViewPDF = false;
    try (Connection conn = DBConnection.getConnection()) {
        String sql = "SELECT can_view FROM pdf_permissions WHERE username = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, username);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            canViewPDF = rs.getBoolean("can_view");
        }
        rs.close();
        ps.close();
    } catch (Exception e) {
        e.printStackTrace();
    }

    // Handle request permission button
    if (request.getParameter("requestPermission") != null) {
        try (Connection conn = DBConnection.getConnection()) {
            String insert = "INSERT INTO pdf_permissions (username, can_view) VALUES (?, FALSE) " +
                            "ON DUPLICATE KEY UPDATE can_view = can_view";
            PreparedStatement ps = conn.prepareStatement(insert);
            ps.setString(1, username);
            ps.executeUpdate();
            ps.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        out.println("<p style='color:blue;'>Permission request sent to admin.</p>");
    }

    // Fetch full name
    String fullName = "User";
    try (Connection conn = DBConnection.getConnection()) {
        String sql = "SELECT fullname FROM users WHERE username = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, username);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) fullName = rs.getString("fullname");
        rs.close();
        ps.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard</title>
    <link rel="stylesheet" type="text/css" href="css/dashboard.css">
   
</head>
<body>
<div class="dashboard-container">
    <h1>Welcome, <%= fullName %>!</h1>
    <p>You have successfully logged in to your dashboard.</p>

    <!-- Google Meet Join Button -->
    <form method="get" action="dashboard.jsp">
        <input type="hidden" name="joinMeet" value="true"/>
        <button type="submit" class="meet-btn">Join Google Meet</button>
    </form>

    <!-- PDF Section -->
    <div class="pdf-section">
        <h2>Today's PDF Document</h2>
        <% if (canViewPDF) { %>
            <iframe src="uploads/Spring and Java By Amit Sir.pdf"></iframe>
        <% } else { %>
            <p style="color:red;">You need admin permission to view this PDF.</p>
            <form method="post" action="dashboard.jsp">
                <button type="submit" name="requestPermission">Request Permission</button>
            </form>
        <% } %>
    </div>

    <!-- Logout -->
    <a href="logout.jsp" class="logout-btn">Logout</a>
</div>
</body>
</html>
