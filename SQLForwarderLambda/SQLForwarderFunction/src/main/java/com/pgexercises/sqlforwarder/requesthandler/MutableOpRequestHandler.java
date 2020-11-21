package com.pgexercises.sqlforwarder.requesthandler;

import com.pgexercises.common.CacheableConnection;
import com.pgexercises.common.DbEnvInfo;
import com.pgexercises.common.DbInitializer;
import com.pgexercises.common.DbSource;
import com.pgexercises.common.QueryResponse;
import com.pgexercises.exceptions.PGEInternalErrorException;
import com.pgexercises.exceptions.PGEUserException;
import com.pgexercises.sqlforwarder.RequestData;
import org.checkerframework.checker.nullness.qual.Nullable;

import java.sql.SQLException;
import java.util.concurrent.TimeUnit;

public class MutableOpRequestHandler implements RequestHandler {

    private final ConnectionOwner connectionOwner;
    private final DbEnvInfo envInfo;


    public MutableOpRequestHandler(DbSource baseUserDbSource, DbSource baseAdminDbSource, DbSource managementConnectionSource, DbEnvInfo envInfo) {
        this.connectionOwner = new ConnectionOwner(baseUserDbSource, baseAdminDbSource, managementConnectionSource);
        this.envInfo = envInfo;
    }

    @Override
    public synchronized @Nullable QueryResponse performQuery(RequestData requestData) throws PGEInternalErrorException, PGEUserException {
        QueryResponse result;
        try {
            result = connectionOwner.getUserConnection().execute(requestData.getQuery());
            if (result == null) {
                result = connectionOwner.getUserConnection().execute("select * from " + requestData.getTableToReturn() + " order by 1");
                if (result == null) {
                    throw new PGEInternalErrorException("Null result set for " + requestData.getTableToReturn());
                }
            }
        } catch (SQLException e) {
            //TODO this is a bit crap - still the possibility of an internal error
            //after all.  Inspect the PSQLState for 400 vs 500 indicator purposes!
            throw new PGEUserException(e.getMessage());
        }
        return result;
    }

    @Override
    public synchronized void cleanupAfterQuery() throws PGEInternalErrorException {
        try {
            connectionOwner.getUserConnection().resetConnectionForPooling();
        } finally {
            connectionOwner.getAdminConnection().resetConnectionForPooling();
        }
    }

    @Override
    public synchronized void preCheck() throws PGEInternalErrorException, PGEUserException {
        connectionOwner.validateConnections();
        resetDb();
    }

    private void resetDb() throws PGEInternalErrorException {
        DbInitializer.resetDb(connectionOwner.getAdminConnection(), envInfo, false, connectionOwner.getWriteableDbOffset(), true);
    }

    private static class ConnectionOwner {
        private @Nullable CacheableConnection userConnection;
        private @Nullable CacheableConnection adminConnection;
        private final CacheableConnection managementConnection;
        private final DbSource baseUserDbSource;
        private final DbSource baseAdminDbSource;
        private int writeableDb;
        private long lastResetTime = System.nanoTime();

        ConnectionOwner(DbSource baseUserDbSource, DbSource baseAdminDbSource, DbSource managementConnectionSource) {
            this.managementConnection = new CacheableConnection(managementConnectionSource);
            this.baseUserDbSource = baseUserDbSource;
            this.baseAdminDbSource = baseAdminDbSource;
            this.writeableDb = -1;
        }

        private CacheableConnection getManagementConnection() {
            return managementConnection;
        }

        public synchronized CacheableConnection getAdminConnection() throws PGEInternalErrorException {
            if (adminConnection == null) {
                throw new PGEInternalErrorException("Code error: writeableDB is not initialised getting admin connection");
            }
            return adminConnection;
        }

        public synchronized CacheableConnection getUserConnection() throws PGEInternalErrorException {
            if (userConnection == null) {
                throw new PGEInternalErrorException("Code error: writeableDB is not initialised getting user connection");
            }
            return userConnection;
        }

        public int getWriteableDbOffset() {
            return writeableDb;
        }

        public synchronized void validateConnections() throws PGEInternalErrorException, PGEUserException {
            if (userConnection == null
                    || adminConnection == null
                    || !getManagementConnection().isTransactionActive()
                    || writeableDb == -1
                    || haveConnectionsAgedOut()) {
                closeConnections();
                writeableDb = reserveWriteableDb(getManagementConnection());
                userConnection = new CacheableConnection(baseUserDbSource.withDbOffset(writeableDb));
                adminConnection = new CacheableConnection(baseAdminDbSource.withDbOffset(writeableDb));
                lastResetTime = System.nanoTime();
            }

            try {
                checkConnection(getUserConnection());
            } finally {
                checkConnection(getAdminConnection());
            }
        }

        private synchronized void checkConnection(CacheableConnection connection) throws PGEInternalErrorException {
            try {
                connection.execute("select 1");
            } catch (Exception e) {
                System.out.println("Connection not working, closing: " + e.getMessage());
                connection.closeConnection();
            }
        }

        private synchronized void closeConnections() throws PGEInternalErrorException {
            System.out.println("Closing connections for mutable request handler");
            writeableDb = -1;
            CacheableConnection userC = userConnection;
            CacheableConnection adminC = adminConnection;
            userConnection = null;
            adminConnection = null;
            // TODO pyramid lol
            try {
                if (userC != null) {
                    userC.closeConnection();
                }
            } finally {
                try {
                    if (adminC != null) {
                        adminC.closeConnection();
                    }
                } finally {
                    try {
                        managementConnection.execute("ROLLBACK");
                    } catch (PGEUserException | SQLException e) {
                        throw new PGEInternalErrorException("couldn't rollback management tran", e);
                    } finally {
                        managementConnection.closeConnection();
                    }
                }
            }
        }

        private synchronized int reserveWriteableDb(CacheableConnection managementConnection) throws PGEUserException, PGEInternalErrorException {
            QueryResponse lockedId;
            try {
                managementConnection.execute("BEGIN");
                lockedId = managementConnection.execute("SELECT lock_id FROM mgmt.lock_list FOR UPDATE SKIP LOCKED LIMIT 1");
            } catch (SQLException e) {
                throw new PGEInternalErrorException("Couldn't lock writeable DB due to error", e);
            }

            String value = lockedId == null || lockedId.getSingleValue() == null ? null : lockedId.getSingleValue();

            if (value == null) {
                throw new PGEUserException("PGExercises is overloaded right now: please retry");
            }
            return Integer.parseInt(value);
        }

        private boolean haveConnectionsAgedOut() {
            boolean agedOut = TimeUnit.HOURS.convert((System.nanoTime() - lastResetTime), TimeUnit.NANOSECONDS) > 12;
            if (agedOut) {
                System.out.println("Connections have aged out. Closing as long running management transactions can impact database health");
            }
            return agedOut;
        }
    }
}
