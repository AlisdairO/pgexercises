

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.text.DecimalFormat;
import java.util.logging.Logger;

import javax.naming.InitialContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.postgresql.util.PGInterval;
import org.postgresql.util.PSQLException;

/**
 * Servlet implementation class SQLForwarder
 */
@WebServlet("/SQLForwarder")
public class SQLForwarder extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final Logger log = Logger.getLogger("SQLForwarder");  

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public SQLForwarder() {
		super();
	}

	/**
	 * Simply takes a string query parameter, and sends it off to run against
	 * the Postgres server.  Does some mungeing of the returned data to make the
	 * formatting equivalent to that produced by our static site generation.
	 * 
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	@SuppressWarnings("unchecked") //JSON.simple is not generic :-/.  Not worth finding another library for this trivial code!
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		Connection c = null;
		boolean success = true;
		JSONObject respJSON = new JSONObject();
		String query = request.getParameter("query");
		log.finer(query);
		if(query.length() > 15000) {
			response.sendError(400, "Request too long.");
		}
		try {
			InitialContext ic = new InitialContext();
			DataSource ds = (DataSource) ic.lookup("java:comp/env/jdbc/pgexercises");
			c = ds.getConnection();
			c.setAutoCommit(true);
			Statement s = c.createStatement();
			
			try {
				s.execute(query);
				ResultSet rs = s.getResultSet();
				if(rs == null) {
					response.sendError(400, "Invalid query");
					success = false;
				} else {
					int cols = rs.getMetaData().getColumnCount();

					JSONArray headers = new JSONArray();
					JSONArray values = new JSONArray();
					respJSON.put("headers", headers);
					respJSON.put("values", values);



					for(int i = 1; i <= cols; i++) {
						headers.add(rs.getMetaData().getColumnName(i));
					}

					while(rs.next()) {
						JSONArray row = new JSONArray();
						values.add(row);
						for(int column = 1; column <= cols; column++) {
							String attrValStr = genString(rs.getObject(column), rs.getMetaData().getColumnType(column));
							row.add(attrValStr);

						}
					}
				}

			} catch (PSQLException e) {
				//TODO this is a bit crap - still the possibility of an internal error
				//after all.  Inspect the PSQLState for 400 vs 500 indicator purposes!
				log.finer(e.getMessage());
				response.sendError(400, e.getMessage());
				success = false;
			}


		} catch (Exception e) { //catch-all for unanticipated errors: make sure we log them.

			log.severe("Encountered error: " + e);
			log.severe(stackTraceToString(e));
			response.sendError(500, e.toString());
			success = false;
		} finally {
			try {
				if(c != null) {
					c.close();
				}
			} catch (SQLException e) {
				log.severe("Unable to close connection: " + e);
				log.severe(stackTraceToString(e));
				response.sendError(500, e.toString());
				success = false;
			}
		}
		if(success) {
			respJSON.writeJSONString(response.getWriter());
		}
	
	}
	
	/*
	 * Performs any required string alterations to normalise formatting between static
	 * site generation and this dynamic query.  This is all rather horrible - in future
	 * I'll be changing this to use a single java library to generate the static and dynamic
	 * query results.
	 */
	private String genString(Object attrVal, int colType) {
		if (attrVal == null) {
			attrVal = "";
		}
		String attrValStr = attrVal.toString();
		
		if(colType == Types.TIMESTAMP) {
			attrValStr = attrValStr.substring(0,attrValStr.lastIndexOf(".0"));
		} else if(colType == Types.DOUBLE 
				|| colType == Types.REAL) {
			//remove trailing zeroes for floats and doubles: helps us match psql output
			attrValStr = attrValStr.replaceAll("\\.00*$", "");
		} else if(attrVal instanceof PGInterval) {
			PGInterval attrValInterval = (PGInterval)attrVal;
			attrValStr = "";
			if(attrValInterval.getYears() > 1) {
				attrValStr += attrValInterval.getYears() + " years "; 
			} else if(attrValInterval.getYears() == 1) {
				attrValStr += attrValInterval.getYears() + " year "; 
			}
			
			if(attrValInterval.getMonths() > 1) {
				attrValStr += attrValInterval.getMonths() + " months "; 
			} else if(attrValInterval.getMonths() == 1) {
				attrValStr += attrValInterval.getMonths() + " month "; 
			}
			
			if(attrValInterval.getDays() > 1) {
				attrValStr += attrValInterval.getDays() + " days "; 
			} else if(attrValInterval.getDays() == 1) {
				attrValStr += attrValInterval.getDays() + " day "; 
			}
			String secs = new DecimalFormat("00.################").format(attrValInterval.getSeconds());
			String time = String.format( "%02d:%02d:%s", attrValInterval.getHours(), attrValInterval.getMinutes(), secs);
			
			if(!time.equals("00:00:00")) {
				attrValStr += time;
			}
			
			attrValStr = attrValStr.trim();
		}
		
		return attrValStr;
		
	}

	public static String stackTraceToString(Exception e) {
		StringWriter errors = new StringWriter();
		e.printStackTrace(new PrintWriter(errors));
		return errors.toString();
	}

}
