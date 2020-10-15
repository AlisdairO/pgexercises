package com.pgexercises;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.text.DecimalFormat;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.postgresql.util.PGInterval;

public class JSONUtils {
	public static int MAX_QUERY_CHARS = 200000;
	
	//Formats the results of a query into a JSON object: basically an array describing headers,
	//and another (two dimensional) array that holds the results
	@SuppressWarnings("unchecked") //JSON.simple is not generic :-/.  Not worth finding another library for this trivial code!
	public static JSONObject queryToJSON(ResultSet rs) throws SQLException, PGEQueryResultSizeTooBigException {

		long approxTotalChars = 0;
		JSONObject respJSON = new JSONObject();
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
				approxTotalChars += attrValStr.length();
				if (approxTotalChars > MAX_QUERY_CHARS) {
					throw new PGEQueryResultSizeTooBigException();
				}
				row.add(attrValStr);
			}
		}
		
		return respJSON;
	}
	
	/*
	 * This is some nasty legacy, from a period where we had a separate querying process for
	 * static site generation vs when the query ran on the actual site (the string output needed
	 * normalising between the two) That has been unified now, so these hacks can be removed.
	 * TODO evaluate if any of these are worth retaining for formatting purposes.
	 * query results.
	 */
	private static String genString(Object attrVal, int colType) {
		if (attrVal == null) {
			return "";
		}
		String attrValStr = attrVal.toString();
		
		if(colType == Types.TIMESTAMP) {
			int fractionLoc = attrValStr.lastIndexOf(".0");
			if (fractionLoc >= 0) {
				attrValStr = attrValStr.substring(0, fractionLoc);
			}
		} else if(colType == Types.DOUBLE 
				|| colType == Types.REAL) {
			//remove trailing zeroes for floats and doubles: helps us match psql output
			attrValStr = attrValStr.replaceAll("\\.00*$", "");
		} else if(attrVal instanceof PGInterval) {
			attrValStr = formatInterval((PGInterval)attrVal);
		}
		
		return attrValStr;	
	}
	
	private static String formatInterval(PGInterval attrValInterval) {
		StringBuilder attrValSB = new StringBuilder();
		if(attrValInterval.getYears() > 1) {
			attrValSB.append(attrValInterval.getYears()).append(" years "); 
		} else if(attrValInterval.getYears() == 1) {
			attrValSB.append(attrValInterval.getYears()).append(" year "); 
		}
		
		if(attrValInterval.getMonths() > 1) {
			attrValSB.append(attrValInterval.getMonths()).append(" months "); 
		} else if(attrValInterval.getMonths() == 1) {
			attrValSB.append(attrValInterval.getMonths()).append(" month "); 
		}
		
		if(attrValInterval.getDays() > 1) {
			attrValSB.append(attrValInterval.getDays()).append(" days "); 
		} else if(attrValInterval.getDays() == 1) {
			attrValSB.append(attrValInterval.getDays()).append(" day "); 
		}
		String secs = new DecimalFormat("00.################").format(attrValInterval.getSeconds());
		String time = String.format( "%02d:%02d:%s", attrValInterval.getHours(), attrValInterval.getMinutes(), secs);
		
		if(!time.equals("00:00:00")) {
			attrValSB.append(time);
		}
		
		return attrValSB.toString().trim();
	}
}
