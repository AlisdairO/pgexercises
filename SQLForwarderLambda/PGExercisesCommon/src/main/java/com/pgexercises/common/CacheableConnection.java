package com.pgexercises.common;

import com.pgexercises.exceptions.PGEInternalErrorException;
import com.pgexercises.exceptions.PGEUserException;
import org.checkerframework.checker.nullness.qual.Nullable;
import org.postgresql.copy.CopyIn;
import org.postgresql.copy.CopyManager;
import org.postgresql.core.BaseConnection;
import org.postgresql.core.TransactionState;

import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class CacheableConnection {
    private @Nullable BaseConnection connection;
    private final DbSource dbSource;

    public CacheableConnection(DbSource dbSource) {
        this.dbSource = dbSource;
    }

    public synchronized void closeConnection() throws PGEInternalErrorException {
        if (connection == null) {
            return;
        }

        Connection c = connection;
        connection = null;
        try {
            c.close();
        } catch (SQLException e) {
            throw new PGEInternalErrorException("Couldn't close connection", e);
        }
    }

    public synchronized void resetConnectionForPooling() throws PGEInternalErrorException {
        if (connection == null) {
            return;
        }

        try (Statement s = connection.createStatement()) {
            s.execute("ROLLBACK; DISCARD ALL;");
        } catch (SQLException e) {
            closeConnection();
            throw new PGEInternalErrorException("Couldn't reset connection for caching", e);
        }
    }

    private synchronized BaseConnection getConnection() throws PGEInternalErrorException {
        ensureConnectionValidity();
        if (connection == null) {
            try {
                connection = (BaseConnection) DriverManager.getConnection(dbSource.getUri().toString() + "/" + dbSource.getDatabase(),
                        dbSource.getUser(),
                        dbSource.getPassword());
            } catch (SQLException e) {
                throw new PGEInternalErrorException("Couldn't create connection", e);
            }
        }
        return connection;
    }

    private synchronized void ensureConnectionValidity() throws PGEInternalErrorException {
        if (connection != null) {
            try {
                executeInternal("select 1", connection);
            } catch (Exception e) {
                closeConnection();
            }
        }
    }

    public synchronized @Nullable QueryResponse execute(String sql) throws SQLException, PGEUserException, PGEInternalErrorException {
        return executeInternal(sql, getConnection());
    }

    private synchronized @Nullable QueryResponse executeInternal(String sql, Connection conn) throws SQLException, PGEUserException {
        try (Statement s = conn.createStatement()) {
            if (s.execute(sql)) {
                try (ResultSet rs = s.getResultSet()) {
                    return new QueryResponse(rs);
                }
            } else {
                return null;
            }
        }
    }

    public synchronized void executeUpdateInternal(String sql) throws PGEInternalErrorException {
        try (Statement s = getConnection().createStatement()) {
            s.executeUpdate(sql);
        } catch (SQLException e) {
            throw new PGEInternalErrorException(e.getMessage(), e);
        }
    }

    public synchronized void doCopyIn(String copyStr, String data) throws SQLException, PGEInternalErrorException {
        CopyManager copyManager = new CopyManager(getConnection());
        CopyIn copyIn = copyManager.copyIn(copyStr);

        try {
            byte[] bytes = data.getBytes(StandardCharsets.UTF_8);
            copyIn.writeToCopy(bytes, 0, bytes.length);
            copyIn.endCopy();
        } finally {
            if (copyIn.isActive()) {
                copyIn.cancelCopy();
            }
        }
    }

    public synchronized boolean isTransactionActive() {
        if (connection == null) {
            return false;
        }
        return connection.getTransactionState() == TransactionState.OPEN;
    }
}