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
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

// TODO refactor the handling of 'connection': this used to be a
// base non-future-y connection, but since switching to async
// initialisation the internal handling is a bit messy
public class CacheableConnection {
    private @Nullable Future<BaseConnection> connection;
    private final DbSource dbSource;

    public CacheableConnection(DbSource dbSource) {
        this.dbSource = dbSource;
        connection = createConnectionAsync(dbSource);
    }

    private static Future<BaseConnection> createConnectionAsync(DbSource dbSource) {
        ExecutorService executor = Executors.newFixedThreadPool(1);
        Callable<BaseConnection> task = () -> {
            String dbUrl = dbSource.getUri().toString() + "/" + dbSource.getDatabase();
            System.out.println("Initialising connection to: " + dbUrl);
            BaseConnection conn = (BaseConnection) DriverManager.getConnection(dbUrl,
                    dbSource.getUser(),
                    dbSource.getPassword());
            System.out.println("Done initialising connection: " + dbUrl);
            return conn;
        };
        return executor.submit(task);
    }

    public synchronized void closeConnection() throws PGEInternalErrorException {
        if (connection == null) {
            return;
        }

        Future<BaseConnection> c = connection;
        connection = null;
        try {
            c.get().close();
        } catch (SQLException | InterruptedException | ExecutionException e) {
            throw new PGEInternalErrorException("Couldn't close connection", e);
        }
    }


    public synchronized void resetConnectionForPooling() throws PGEInternalErrorException {
        Connection conn = getExistingConnection();
        if (conn == null) {
            return;
        }

        try (Statement s = conn.createStatement()) {
            s.execute("ROLLBACK; DISCARD ALL;");
        } catch (SQLException e) {
            closeConnection();
            throw new PGEInternalErrorException("Couldn't reset connection for caching", e);
        }
    }

    private synchronized BaseConnection getOrCreateConnection() throws PGEInternalErrorException {
        ensureConnectionValidity();
        try {
            if (connection == null) {
                connection = createConnectionAsync(dbSource);
            }
            return connection.get();
        } catch (ExecutionException | InterruptedException e) {
            throw new PGEInternalErrorException("Couldn't create connection", e);
        }
    }

    private synchronized @Nullable BaseConnection getExistingConnection() throws PGEInternalErrorException {
        if (connection == null) {
            return null;
        }
        try {
            return connection.get();
        } catch (ExecutionException | InterruptedException e) {
            throw new PGEInternalErrorException("Couldn't create connection", e);
        }
    }

    private synchronized void ensureConnectionValidity() throws PGEInternalErrorException {
        Connection conn = getExistingConnection();
        if (conn != null) {
            try {
                executeInternal("select 1", conn);
            } catch (Exception e) {
                closeConnection();
            }
        }
    }

    public synchronized @Nullable QueryResponse execute(String sql) throws SQLException, PGEUserException, PGEInternalErrorException {
        return executeInternal(sql, getOrCreateConnection());
    }

    private synchronized @Nullable QueryResponse executeInternal(String sql, Connection conn) throws SQLException, PGEUserException {
        System.out.println("EXEC Q: " + sql);
        try (Statement s = conn.createStatement()) {
            if (s.execute(sql)) {
                try (ResultSet rs = s.getResultSet()) {
                    QueryResponse qr = new QueryResponse(rs);
                    System.out.println("DONE EXEC Q: " + sql);
                    return qr;
                }
            } else {
                return null;
            }
        }
    }

    public synchronized void executeUpdateInternal(String sql) throws PGEInternalErrorException {
        System.out.println("Start exec U");
        try (Statement s = getOrCreateConnection().createStatement()) {
            System.out.println("EXEC U: " + sql);
            s.executeUpdate(sql);
            System.out.println("DONE EXEC U: " + sql);
        } catch (SQLException e) {
            throw new PGEInternalErrorException(e.getMessage(), e);
        }
    }

    public synchronized void doCopyIn(String copyStr, String data) throws SQLException, PGEInternalErrorException {
        System.out.println("COPY IN");
        CopyManager copyManager = new CopyManager(getOrCreateConnection());
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
        System.out.println("DONE COPY IN");
    }

    public synchronized boolean isTransactionActive() throws PGEInternalErrorException {
        BaseConnection conn = getExistingConnection();
        if (conn == null) {
            return false;
        }
        return conn.getTransactionState() == TransactionState.OPEN;
    }

    public synchronized void waitOnInit() throws PGEInternalErrorException {
        this.ensureConnectionValidity();
    }
}