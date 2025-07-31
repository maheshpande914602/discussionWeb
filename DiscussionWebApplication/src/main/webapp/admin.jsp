<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat, repository.DBConnection" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null || !"admin".equalsIgnoreCase(username)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String message = "";

    // Handle PDF filename update
    if (request.getParameter("updatePdf") != null) {
        String pdfFilename = request.getParameter("pdfFilename");
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "UPDATE settings SET value = ? WHERE setting_key = 'pdf_filename'";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, pdfFilename);
            int updated = ps.executeUpdate();
            if (updated == 0) {
                // insert if not exists
                sql = "INSERT INTO settings (setting_key, value) VALUES ('pdf_filename', ?)";
                ps = conn.prepareStatement(sql);
                ps.setString(1, pdfFilename);
                ps.executeUpdate();
            }
            ps.close();
            message = "PDF filename updated successfully.";
        } catch (Exception e) {
            message = "Error updating PDF filename: " + e.getMessage();
        }
    }

    // Handle Google Meet link update
    if (request.getParameter("updateMeet") != null) {
        String meetLink = request.getParameter("meetLink");
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "UPDATE settings SET value = ? WHERE setting_key = 'google_meet_link'";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, meetLink);
            int updated = ps.executeUpdate();
            if (updated == 0) {
                sql = "INSERT INTO settings (setting_key, value) VALUES ('google_meet_link', ?)";
                ps = conn.prepareStatement(sql);
                ps.setString(1, meetLink);
                ps.executeUpdate();
            }
            ps.close();
            message = "Google Meet link updated successfully.";
        } catch (Exception e) {
            message = "Error updating Google Meet link: " + e.getMessage();
        }
    }

    // Handle approval of PDF permission requests
    String approveUser = request.getParameter("approve");
    if (approveUser != null) {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "UPDATE pdf_permissions SET can_view = TRUE WHERE username = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, approveUser);
            int updated = ps.executeUpdate();
            ps.close();
            if (updated > 0) {
                message = "Permission approved for user: " + approveUser;
            } else {
                message = "User not found or permission already granted.";
            }
        } catch (Exception e) {
            message = "Error approving permission: " + e.getMessage();
        }
    }

    // *** New: Handle approval of user registrations ***
    String approveRegistrationUser = request.getParameter("approveReg");
    if (approveRegistrationUser != null) {
        try (Connection conn = DBConnection.getConnection()) {
            // Adjust this SQL if your DB schema differs
            String sql = "UPDATE users SET is_approved = TRUE WHERE username = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, approveRegistrationUser);
            int updated = ps.executeUpdate();
            ps.close();
            if (updated > 0) {
                message = "Registration approved for user: " + approveRegistrationUser;
            } else {
                message = "User not found or already approved.";
            }
        } catch (Exception e) {
            message = "Error approving registration: " + e.getMessage();
        }
    }

    // Fetch current PDF filename and meet link
    String currentPdfFilename = "";
    String currentMeetLink = "";
    try (Connection conn = DBConnection.getConnection()) {
        String sql = "SELECT setting_key, value FROM settings WHERE setting_key IN ('pdf_filename', 'google_meet_link')";
        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            String key = rs.getString("setting_key");
            if ("pdf_filename".equals(key)) {
                currentPdfFilename = rs.getString("value");
            } else if ("google_meet_link".equals(key)) {
                currentMeetLink = rs.getString("value");
            }
        }
        rs.close();
        ps.close();
    } catch (Exception e) {
        // ignore or log
    }

    // Fetch pending permission requests
    List<String> pendingUsers = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection()) {
        String sql = "SELECT username FROM pdf_permissions WHERE can_view = FALSE";
        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            pendingUsers.add(rs.getString("username"));
        }
        rs.close();
        ps.close();
    } catch (Exception e) {
        // ignore or log
    }

    // *** New: Fetch pending registration requests ***
    List<String> pendingRegistrations = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection()) {
        // Adjust this query if your status column or table name differs
        String sql = "SELECT username FROM users WHERE is_approved = FALSE";
        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            pendingRegistrations.add(rs.getString("username"));
        }
        rs.close();
        ps.close();
    } catch (Exception e) {
        // ignore or log
    }

    // Handle attendance date filter
    String attendanceDateParam = request.getParameter("attendanceDate");
    java.util.Date attendanceDate = null;
    if (attendanceDateParam != null && !attendanceDateParam.trim().isEmpty()) {
        try {
            attendanceDate = new SimpleDateFormat("yyyy-MM-dd").parse(attendanceDateParam);
        } catch (Exception e) {
            attendanceDate = null;
        }
    }

    // Fetch attendance records filtered by date (or all if no date)
    List<Map<String, String>> attendanceRecords = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection()) {
        String sql = "SELECT ma.id, ma.username, ma.join_time, u.fullname FROM meet_attendance ma " +
                     "JOIN users u ON ma.username = u.username ";
        if (attendanceDate != null) {
            sql += "WHERE DATE(ma.join_time) = ? ";
        }
        sql += "ORDER BY ma.join_time DESC";
        PreparedStatement ps = conn.prepareStatement(sql);
        if (attendanceDate != null) {
            ps.setDate(1, new java.sql.Date(attendanceDate.getTime()));
        }
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, String> record = new HashMap<>();
            record.put("id", rs.getString("id"));
            record.put("username", rs.getString("username"));
            record.put("fullname", rs.getString("fullname"));
            record.put("join_time", rs.getString("join_time"));
            attendanceRecords.add(record);
        }
        rs.close();
        ps.close();
    } catch (Exception e) {
        // ignore or log
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Panel</title>
    <link rel="stylesheet" href="css/admin.css">
</head>
<body>
<div class="admin-container">
    <h1>Admin Panel</h1>

    <% if (!message.isEmpty()) { %>
        <div class="message"><%= message %></div>
    <% } %>

    <section>
        <h2>Update PDF Filename</h2>
        <form method="post" action="admin.jsp">
            <input type="text" name="pdfFilename" placeholder="e.g. Spring and Java By Amit Sir.pdf" value="<%= currentPdfFilename %>" required>
            <button type="submit" name="updatePdf">Update PDF</button>
        </form>
        <p><small>Make sure the PDF file is uploaded in the <code>uploads/</code> folder.</small></p>
    </section>

    <section>
        <h2>Update Google Meet Link</h2>
        <form method="post" action="admin.jsp">
            <input type="url" name="meetLink" placeholder="Google Meet link" value="<%= currentMeetLink %>" required>
            <button type="submit" name="updateMeet">Update Meet Link</button>
        </form>
    </section>

    <section>
        <h2>Pending PDF Access Requests</h2>
        <% if (pendingUsers.isEmpty()) { %>
            <p>No pending requests.</p>
        <% } else { %>
            <ul>
                <% for (String user : pendingUsers) { %>
                    <li>
                        <%= user %>
                        <a href="admin.jsp?approve=<%= user %>" onclick="return confirm('Approve PDF access for <%= user %>?')">Approve</a>
                    </li>
                <% } %>
            </ul>
        <% } %>
    </section>

    <!-- New Section for Pending Registration Requests -->
    <section>
        <h2>Pending Registration Requests</h2>
        <% if (pendingRegistrations.isEmpty()) { %>
            <p>No pending registration requests.</p>
        <% } else { %>
            <ul>
                <% for (String user : pendingRegistrations) { %>
                    <li>
                        <%= user %>
                        <a href="admin.jsp?approveReg=<%= user %>" onclick="return confirm('Approve registration for <%= user %>?')">Approve</a>
                    </li>
                <% } %>
            </ul>
        <% } %>
    </section>

    <section>
        <h2>Attendance Records</h2>
        <form method="get" action="admin.jsp" class="attendance-filter-form">
            <label for="attendanceDate">Filter by date:</label>
            <input type="date" id="attendanceDate" name="attendanceDate" value="<%= attendanceDateParam != null ? attendanceDateParam : "" %>">
            <button type="submit">Filter</button>
            <a href="admin.jsp" style="margin-left:10px;">Reset</a>
        </form>

        <table class="attendance-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Username</th>
                    <th>Full Name</th>
                    <th>Join Time</th>
                </tr>
            </thead>
            <tbody>
            <% if (attendanceRecords.isEmpty()) { %>
                <tr><td colspan="4">No attendance records found.</td></tr>
            <% } else { 
                for (Map<String,String> record : attendanceRecords) { %>
                    <tr>
                        <td><%= record.get("id") %></td>
                        <td><%= record.get("username") %></td>
                        <td><%= record.get("fullname") %></td>
                        <td><%= record.get("join_time") %></td>
                    </tr>
            <%  } 
               } %>
            </tbody>
        </table>
    </section>

    <a href="logout.jsp" class="logout-btn">Logout</a>
</div>
</body>
</html>
