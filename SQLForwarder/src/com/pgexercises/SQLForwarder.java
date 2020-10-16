package com.pgexercises;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.logging.Logger;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import org.json.simple.JSONObject;

@WebServlet("/SQLForwarder")
public class SQLForwarder extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final Logger log = Logger.getLogger("SQLForwarder");
	private static final int WRITABLE_DB_COUNT = 100;
	private final ArrayList<WriteableDbSource> availableWriters;
	private final DataSource readOnlyDataSource;

	public SQLForwarder() throws NamingException, IOException {
		super();
		InitialContext ic = new InitialContext();
		readOnlyDataSource = (DataSource) ic.lookup("java:comp/env/jdbc/pgexercises");
		availableWriters = new ArrayList<>(WRITABLE_DB_COUNT);
		for (int i = 0; i < WRITABLE_DB_COUNT; i++) {
			availableWriters.add(new WriteableDbSource(
					(DataSource) ic.lookup("java:comp/env/jdbc/pgexerciseswrite" + i),
					(DataSource) ic.lookup("java:comp/env/jdbc/pgexercisesadmin" + i)
					));
		}
	}

	/**
	 * By default, simply takes a string query parameter, and sends it off to run against
	 * the Postgres server.  Does some mungeing of the returned data to make the
	 * formatting equivalent to that produced by our static site generation.
	 * 
	 * If the 'writeable' parameter is set, takes a different codepath whereby we
	 * execute the DML/DDL against a round-robin rotating set of databases, which we recreate
	 * every time a query is performed.
	 * 
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		JSONObject respJSON = null;
		String writeable = request.getParameter("writeable");
		String tableToReturn = null;
		if ("1".equals(writeable)) {
			tableToReturn = request.getParameter("tableToReturn");
			if (tableToReturn == null) {
				response.setStatus(400);
				response.getWriter().println("Must specify table to return for writeable query");
				return;
			}
		}
		String query = request.getParameter("query");
		if(query.length() > 15000) {
			response.setStatus(400);
			response.getWriter().println("Request too long.");
			return;
		}
		log.finer(query);

		try {
			try {
				if ("1".equals(writeable)) {
					respJSON = handleUpdate(query, tableToReturn);
				} else {
					respJSON = handleQuery(query);
				}
			} catch (SQLException e) {
				//TODO this is a bit crap - still the possibility of an internal error
				//after all.  Inspect the PSQLState for 400 vs 500 indicator purposes!
				log.finer(e.getMessage());
				response.setStatus(400);
				response.getWriter().println(e.getMessage());
				return;
			} catch (PGEQueryResultSizeTooBigException e) {
				response.setStatus(400);
				response.getWriter().println("Query produced too many results");
				return;
			}
		} catch (Exception e) { //catch-all for unanticipated errors: make sure we log them.
			log.severe("Encountered error: " + e);
			log.severe(stackTraceToString(e));
			response.sendError(500, e.toString());
			e.printStackTrace();
			return;
		}
		if(respJSON != null) {
			respJSON.writeJSONString(response.getWriter());
		}
	}

	private JSONObject handleQuery(String query) throws SQLException, PGEQueryResultSizeTooBigException {
		try (Connection c = readOnlyDataSource.getConnection();
				Statement s = c.createStatement();
				ResultSet rs = s.executeQuery(query);
				) {
			return JSONUtils.queryToJSON(rs);	
		}
	}

	private JSONObject handleUpdate(String update, String tableToReturn) throws SQLException, IOException, PGEQueryResultSizeTooBigException {
		return doInNextWriteableDataSource(new CallOnWriter(getServletContext(), update, tableToReturn));
	}

	private JSONObject doInNextWriteableDataSource(CallOnWriter toCall) throws SQLException, PGEQueryResultSizeTooBigException {
		WriteableDbSource writeableDbSource = null;
		while(true) {
			synchronized(this) {
				if (availableWriters.size() > 0) {
					writeableDbSource = availableWriters.remove(availableWriters.size() - 1);
					break;
				}
			}
			try {
				Thread.sleep(20);
			} catch (InterruptedException e) {
				throw new RuntimeException("Error: interrupted");
			}
		}
		try {
			return toCall.runUsingDataSource(writeableDbSource);
		} finally {
			synchronized(this) {
				availableWriters.add(writeableDbSource);
			}
		}
	}

	private static String stackTraceToString(Exception e) {
		StringWriter errors = new StringWriter();
		e.printStackTrace(new PrintWriter(errors));
		return errors.toString();
	}
}
