package entity;

public class User {
	private String fullName;
	private String username;
	private String email;
	private String password;
	private String mobNumber;
	private String batchCode;

	public User(String fullName, String username, String email, String password, String mobNumber, String batchCode) {
		this.fullName = fullName;
		this.username = username;
		this.email = email;
		this.password = password;
		this.mobNumber = mobNumber;
		this.batchCode = batchCode;
	}

	public String getFullName() {
		return fullName;
	}

	public void setFullName(String fullName) {
		this.fullName = fullName;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getMobNumber() {
		return mobNumber;
	}

	public void setMobNumber(String mobNumber) {
		this.mobNumber = mobNumber;
	}

	public String getBatchCode() {
		return batchCode;
	}

	public void setBatchCode(String batchCode) {
		this.batchCode = batchCode;
	}

}
