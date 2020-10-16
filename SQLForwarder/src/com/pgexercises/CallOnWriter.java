package com.pgexercises;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Scanner;

import javax.servlet.ServletContext;

import org.json.simple.JSONObject;
import org.postgresql.copy.CopyIn;
import org.postgresql.copy.CopyManager;
import org.postgresql.core.BaseConnection;

class CallOnWriter {
	private final String query;
	private final String tableToReturn;
	private final String recreateSchemaSQL;
	private final String bookingsData;
	private final String facilitiesData;
	private final String membersData;
	private final String finaliseRecreateSQL;

	public CallOnWriter(ServletContext servletContext, String query, String tableToReturn) throws IOException {
		this.query = query;
		this.tableToReturn = tableToReturn;
		recreateSchemaSQL = getResourceAsString(servletContext, "/WEB-INF/SQL/clubdata-schemaonly.sql");
		bookingsData = getResourceAsString(servletContext, "/WEB-INF/SQL/clubdata-bookings.sql");
		facilitiesData = getResourceAsString(servletContext, "/WEB-INF/SQL/clubdata-facilities.sql");
		membersData = getResourceAsString(servletContext, "/WEB-INF/SQL/clubdata-members.sql");
		finaliseRecreateSQL = getResourceAsString(servletContext, "/WEB-INF/SQL/clubdata-finalise.sql");
	}


	private String getResourceAsString(ServletContext servletContext, String resource) throws IOException {
		try (
				InputStream is = servletContext.getResourceAsStream(resource);
				Scanner stemp = new java.util.Scanner(is);
				Scanner s = stemp.useDelimiter("\\A");) {
			return s.hasNext() ? s.next() : "";
		}
	}

	public JSONObject runUsingDataSource(WriteableDbSource writeableDbSource) throws SQLException, PGEQueryResultSizeTooBigException {
		try (Connection adminTempConn = writeableDbSource.getAdminDataSource().getConnection();
				Connection userTempConn = writeableDbSource.getUserDataSource().getConnection();
				Statement adminStatement = adminTempConn.createStatement();
				Statement userStatement = userTempConn.createStatement();
				) {
			BaseConnection adminConnection = (BaseConnection)adminTempConn.unwrap(BaseConnection.class);
			resetDb(adminConnection, adminStatement);
			JSONObject toReturn = doDML(userStatement);
			if (toReturn == null) {
				toReturn = getReturnTableContents(userStatement);
			}

			return toReturn;
		}
	}

	private JSONObject doDML(Statement userStatement) throws SQLException, PGEQueryResultSizeTooBigException {
		userStatement.execute(query);
		try (ResultSet rs = userStatement.getResultSet()) {
			if (rs != null) {
				return JSONUtils.queryToJSON(rs);
			}
		}
		return null;
	}

	private JSONObject getReturnTableContents(Statement userStatement) throws SQLException, PGEQueryResultSizeTooBigException {
		// Normally string concatenation with user input is bad, but we
		// let the user do whatever they have permissions to do anyway :-).
		try (ResultSet rs = userStatement.executeQuery("select * from " + tableToReturn + " order by 1")) {
			return JSONUtils.queryToJSON(rs);
		}
	}

	private void resetDb(BaseConnection adminConnection, Statement adminStatement) throws SQLException {
		adminStatement.executeUpdate("drop schema if exists cd cascade");
		adminStatement.executeUpdate(recreateSchemaSQL);
		doCopyIn(adminConnection, "COPY bookings (bookid, facid, memid, starttime, slots) FROM stdin", bookingsData);
		doCopyIn(adminConnection, "COPY facilities (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance) FROM stdin;", facilitiesData);
		doCopyIn(adminConnection, "COPY members (memid, surname, firstname, address, zipcode, telephone, recommendedby, joindate) FROM stdin;", membersData);
		adminStatement.executeUpdate(finaliseRecreateSQL);
	}

	private void doCopyIn(BaseConnection connection, String copyStr, String data) throws SQLException {
		CopyManager copyManager = new CopyManager(connection);
		CopyIn copyIn = copyManager.copyIn(copyStr);

		try {
			byte[] bytes = data.getBytes();
			copyIn.writeToCopy(bytes, 0, bytes.length);
			copyIn.endCopy();
		} finally {
			if (copyIn.isActive()) {
				copyIn.cancelCopy();
			}
		}
	}

}