package com.pgexercises.common;

import com.pgexercises.exceptions.PGEUserException;
import org.checkerframework.checker.nullness.qual.Nullable;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.postgresql.util.PGInterval;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class QueryResponse {
    public final static int MAX_QUERY_CHARS = 200000;

    private final String[] headers;
    private final List<String[]> values;

    public QueryResponse(ResultSet rs) throws SQLException, PGEUserException {

        long approxTotalChars = 0;
        int cols = rs.getMetaData().getColumnCount();
        values = new ArrayList<>();
        headers = new String[rs.getMetaData().getColumnCount()];
        for(int i = 1; i <= cols; i++) {
            headers[i-1] = (rs.getMetaData().getColumnName(i));
        }

        while(rs.next()) {
            String[] row = new String[cols];
            values.add(row);
            for(int column = 1; column <= cols; column++) {
                String attrValStr = genString(rs.getObject(column), rs.getMetaData().getColumnType(column));
                approxTotalChars += attrValStr.length();
                if (approxTotalChars > MAX_QUERY_CHARS) {
                    throw new PGEUserException("Attempted to run a query that was too large");
                }
                row[column-1] = attrValStr;
            }
        }
    }

    public List<String[]> getValues() {
        return Collections.unmodifiableList(values);
    }

    // JSON.simple is not generic :-/.  Not worth using another library for this trivial
    // code - jackson adds a surprising amount to the class space usage, which is disadvantageous
    // for Lambda weight
    @SuppressWarnings("unchecked")
    public JSONObject toJson() {
        JSONObject respJSON = new JSONObject();
        JSONArray jsonHeaders = new JSONArray();
        JSONArray jsonValues = new JSONArray();
        respJSON.put("headers", jsonHeaders);
        respJSON.put("values", jsonValues);
        Collections.addAll(jsonHeaders, headers);

        for (String[] row : values) {
            JSONArray jsonRow = new JSONArray();
            Collections.addAll(jsonRow, row);
            jsonValues.add(jsonRow);
        }

        return respJSON;
    }

    public @Nullable String getSingleValue() {
         if (getValues().size() != 1 || getValues().get(0).length != 1) {
             return null;
         }
         return getValues().get(0)[0];
    }

    /*
     * This is some nasty legacy, from a period where we had a separate querying process for
     * static site generation vs when the query ran on the actual site (the string output needed
     * normalising between the two) That has been unified now, so these hacks can be removed.
     * TODO evaluate if any of these are worth retaining for formatting purposes.
     * query results.
     */
    private static String genString(@Nullable Object attrVal, int colType) {
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
