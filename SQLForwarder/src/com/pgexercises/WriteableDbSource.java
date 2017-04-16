package com.pgexercises;

import java.sql.SQLException;

import javax.sql.DataSource;

public class WriteableDbSource {
	private final DataSource userDs;
	private final DataSource adminDs;

	public WriteableDbSource(DataSource userDs, DataSource adminDs) {
		this.userDs = userDs;
		this.adminDs = adminDs;
	}

	public DataSource getUserDataSource() throws SQLException {
		return userDs;
	}

	public DataSource getAdminDataSource() throws SQLException {
		return adminDs;
	}
}