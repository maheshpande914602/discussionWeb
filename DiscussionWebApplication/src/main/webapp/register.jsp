<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, repository.DBConnection"%>
<!DOCTYPE html>
<html>
<head>
<title>User Registration</title>
<link rel="stylesheet" type="text/css" href="css/register.css">
<script>
	function validateForm() {
		const fullname = document.forms["regForm"]["fullname"].value.trim();
		const username = document.forms["regForm"]["username"].value.trim();
		const email = document.forms["regForm"]["email"].value.trim();
		const mobile = document.forms["regForm"]["mobileNumber"].value.trim();
		const batchCode = document.forms["regForm"]["batchCode"].value.trim();
		const password = document.forms["regForm"]["password"].value;
		const confirmPassword = document.forms["regForm"]["confirmPassword"].value;

		if (!fullname || !username || !email || !mobile || !batchCode
				|| !password || !confirmPassword) {
			alert("All fields are required.");
			return false;
		}

		const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
		if (!emailRegex.test(email)) {
			alert("Invalid email format.");
			return false;
		}

		const mobileRegex = /^[6-9][0-9]{9}$/;
		if (!mobileRegex.test(mobile)) {
		    alert("Mobile number must be 10 digits and start with 6, 7, 8, or 9.");
		    return false;
		}

		const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$%^&+=!]).{6,}$/;
		if (!passwordRegex.test(password)) {
			alert("Password must be at least 6 characters long and include uppercase, lowercase, number, and special character.");
			return false;
		}

		if (password !== confirmPassword) {
			alert("Passwords do not match.");
			return false;
		}

		const userId = document.getElementById('userid')?.value.trim();

		if (userId === "") {
			alert("User ID cannot be empty.");
			return false;
		} else if (userId === "existingUser123") {
			alert("User ID is already present.");
			return false;
		}

		return true;
	}
</script>
</head>
<body>

	<h2>User Registration</h2>
	<form name="regForm" method="post" action="register.jsp" onsubmit="return validateForm()">
		<label>Full Name:</label> 
		<input type="text" name="fullname" required placeholder="Enter full name"> 

		<label>Username:</label> 
		<input type="text" name="username" required placeholder="Enter username">

		<label>Email:</label> 
		<input type="email" name="email" required placeholder="Enter email"> 

		<label>Mobile Number:</label> 
		<input type="text" name="mobileNumber" required placeholder="Enter mobile number"> 

		<label>Batch Code:</label>
		<input type="text" name="batchCode" required placeholder="Enter batch code"> 

		<label>Password:</label> 
		<input type="password" name="password" required placeholder="Enter password">

		<label>Confirm Password:</label> 
		<input type="password" name="confirmPassword" required placeholder="Confirm password">

		<input type="submit" value="Register">
	</form>

	<%
	String fullname = request.getParameter("fullname");
	String username = request.getParameter("username");
	String email = request.getParameter("email");
	String mobileNumber = request.getParameter("mobileNumber");
	String batchCode = request.getParameter("batchCode");
	String password = request.getParameter("password");
	String confirmPassword = request.getParameter("confirmPassword");

	if (fullname != null && username != null && email != null && mobileNumber != null && batchCode != null
			&& password != null && confirmPassword != null) {

		if (!password.equals(confirmPassword)) {
			out.println("<script>alert('Passwords do not match!');</script>");
		} else {
			try (Connection conn = DBConnection.getConnection()) {
				String sql = "INSERT INTO users (fullname, username, email, mobile_number, batch_code, password, is_approved) VALUES (?, ?, ?, ?, ?, ?, FALSE)";
				PreparedStatement ps = conn.prepareStatement(sql);
				ps.setString(1, fullname);
				ps.setString(2, username);
				ps.setString(3, email);
				ps.setString(4, mobileNumber);
				ps.setString(5, batchCode);
				ps.setString(6, password); // NOTE: hash password in production

				int result = ps.executeUpdate();
				if (result > 0) {
					out.println("<script>");
					out.println("alert('Registration successful! Wait for admin approval.');");
					out.println("window.location = 'index.jsp';");
					out.println("</script>");
				} else {
					out.println("<script>alert('Registration failed. Try again.');</script>");
				}

			} catch (SQLException e) {
				out.println("<script>alert('Database error: " + e.getMessage().replace("'", "\\'") + "');</script>");
			}
		}
	}
	%>

</body>
</html>
