package com.pgexercises.sqlforwarder;

import com.pgexercises.exceptions.PGEUserException;
import org.checkerframework.checker.nullness.qual.Nullable;
import org.postgresql.core.NativeQuery;
import org.postgresql.core.Parser;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class RequestData {
    private final boolean writeable;
    private final @Nullable String tableToReturn;
    private final String query;

    public RequestData(Map<String, String> params) throws PGEUserException {
        this.writeable = validateWriteableParam(params.get("writeable"));
        this.tableToReturn = validateTableToReturn(params.get("tableToReturn"), writeable);
        this.query = validateQuery(params.get("query"));
    }

    public RequestData(String query) throws PGEUserException {
        this.writeable = false;
        this.tableToReturn = null;
        this.query = validateQuery(query);
    }

    private static @Nullable String validateTableToReturn(@Nullable String tableToReturn, boolean writeable) throws PGEUserException {
        if (writeable && tableToReturn == null) {
            throw new PGEUserException("Must specify table to return for writeable query");
        }
        return tableToReturn;
    }

    private static boolean validateWriteableParam(@Nullable String writeable) throws PGEUserException {
        if (writeable == null || writeable.equals("0")) {
            return false;
        } else if (writeable.equals("1")) {
            return true;
        } else {
            throw new PGEUserException("writeable param does not have a valid value: valid values are 0 or 1");
        }
    }

    private static String validateQuery(@Nullable String sql) throws PGEUserException {
        if (sql == null) {
            throw new PGEUserException("Must supply a query");
        }
        if (sql.length() > 15000) {
            throw new PGEUserException("Request too long.");
        }
        List<NativeQuery> queries;
        try {
            queries = Parser.parseJdbcSql(sql, true, false, true, false);
        } catch (SQLException e) {
            throw new PGEUserException(e.getMessage());
        }
        if (queries.size() > 1) {
            throw new PGEUserException("Multiple queries specified: this is not allowed");
        }
        return sql;
    }

    @Override
    public String toString() {
        return String.format("writeable: %b,%n tableToReturn: %s,%n query: %s%n", writeable, tableToReturn, query);
    }

    public boolean isWriteable() {
        return writeable;
    }

    public @Nullable String getTableToReturn() {
        return tableToReturn;
    }

    public String getQuery() {
        return query;
    }
}
