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
import java.util.Random;
import java.util.concurrent.TimeUnit;

public class MutableOpRequestHandler implements RequestHandler {

    private final ConnectionOwner connectionOwner;
    private final DbEnvInfo envInfo;

    public MutableOpRequestHandler(DbSource baseUserDbSource, DbSource baseAdminDbSource, DbSource managementConnectionSource, DbEnvInfo envInfo) throws PGEUserException, PGEInternalErrorException {
        this.connectionOwner = new ConnectionOwner(baseUserDbSource, baseAdminDbSource, managementConnectionSource, envInfo.getWriteableDbCount());
        this.envInfo = envInfo;
    }

    public synchronized void initPreWarm() throws PGEUserException, PGEInternalErrorException {
        DbInitializer.warmClass();
        connectionOwner.initConnections();
    }

    @Override
    public synchronized @Nullable QueryResponse performQuery(RequestData requestData) throws PGEInternalErrorException, PGEUserException {
        System.out.println("perform query");
        QueryResponse result;
        try {
            result = connectionOwner.getUserConnection().execute(requestData.getQuery());
            if (result == null) {
                connectionOwner.getUserConnection().resetConnectionForPooling();
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

    public synchronized void waitOnInit() throws PGEInternalErrorException {
        System.out.println("wait on init");
        // check each of the connections has finished initialising, so we don't end up
        // freezing the lambda with connections in some half-initialised state, since who knows
        // what would happen then...
        connectionOwner.getManagementConnection().waitOnInit();
        connectionOwner.getAdminConnection().waitOnInit();
        connectionOwner.getUserConnection().waitOnInit();
        System.out.println("done wait on init");
    }

    @Override
    public synchronized void preCheck() throws PGEInternalErrorException, PGEUserException {
        connectionOwner.validateConnections();
        resetDb();
    }

    private synchronized void resetDb() throws PGEInternalErrorException {
        System.out.println("Reset DB");
        DbInitializer.resetDb(connectionOwner.getAdminConnection(), envInfo, false, connectionOwner.getWriteableDbOffset(), true);
    }

    private static class ConnectionOwner {
        private @Nullable CacheableConnection userConnection;
        private @Nullable CacheableConnection adminConnection;
        private final CacheableConnection managementConnection;
        private final DbSource baseUserDbSource;
        private final DbSource baseAdminDbSource;
        private final int writeableDbCount;
        private int writeableDb;
        private long lastResetTime = System.nanoTime();

        ConnectionOwner(DbSource baseUserDbSource, DbSource baseAdminDbSource, DbSource managementConnectionSource, int writeableDbCount) throws PGEUserException, PGEInternalErrorException {
            this.managementConnection = new CacheableConnection(managementConnectionSource);
            this.baseUserDbSource = baseUserDbSource;
            this.baseAdminDbSource = baseAdminDbSource;
            this.writeableDbCount = writeableDbCount;
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
                System.out.println(String.format("UserConnection null? : %b, adminConnection null? : %b" +
                        "Management connection tran active? : %b, writeableDb: %d, connections aged out? : %b",
                        userConnection == null, adminConnection == null, getManagementConnection().isTransactionActive(),
                        writeableDb, haveConnectionsAgedOut()));
                closeAllConnections();
                initConnections();
            }

            try {
                System.out.println("Checking user connection");
                checkConnection(getUserConnection());
            } finally {
                System.out.println("Checking admin connection");
                checkConnection(getAdminConnection());
            }
            System.out.println("Done checking connections");
        }

        public synchronized void initConnections() throws PGEUserException, PGEInternalErrorException {
            // Connection initialisation is a little complicated, because to compensate for the
            // fact that we have to init frequently in a lambda environment, (even with provisioned
            // concurrency) we want to do everything
            // in parallel during the lambda init phase (where we get more CPU shares). As a result
            // we pick a writeable DB in advance and hope it's free. In most cases it will be, but
            // if it's not we close the connection and go through the slow path where we lock the db
            // first then do connection init.
            //
            // This would be much simpler if there was some ability to do processing-after-return in Lambda.
            // Mutable operations are the exception in PGExercises, so in an ideal case we'd make the
            // following approach:
            // - receive request
            // - greedily init the immutable connection
            // - start initing the mutable connections on another thread
            // - process request and return
            // - finish initing mutable connections
            //
            // Sadly this doesn't work, so we're left with a choice between forcing init of all connections
            // before return, or giving a poor/slow experience on mutable requests. For now we're seeing if
            // we can make option 1 fast enough.
            //
            // TODO: connection establishment is weirdly slow, should investigate...
            int desiredWriteableDb = getRandomDbNumber();
            try {
                userConnection = new CacheableConnection(baseUserDbSource.withDbOffset(desiredWriteableDb));
                adminConnection = new CacheableConnection(baseAdminDbSource.withDbOffset(desiredWriteableDb));
                writeableDb = reserveWriteableDb(getManagementConnection(), desiredWriteableDb);
                if (writeableDb != desiredWriteableDb) {
                    closeWriteableDbConnections();
                    userConnection = new CacheableConnection(baseUserDbSource.withDbOffset(writeableDb));
                    adminConnection = new CacheableConnection(baseAdminDbSource.withDbOffset(writeableDb));
                }
            } catch (PGEUserException | PGEInternalErrorException e) {
                closeAllConnections();
                throw e;
            }
            lastResetTime = System.nanoTime();
        }

        private int getRandomDbNumber() {
            return new Random().nextInt(writeableDbCount) + 1;
        }

        private synchronized void checkConnection(CacheableConnection connection) throws PGEInternalErrorException {
            try {
                connection.execute("select 1");
            } catch (Exception e) {
                System.out.println("Connection not working, closing: " + e.getMessage());
                connection.closeConnection();
            }
        }

        private synchronized void closeAllConnections() throws PGEInternalErrorException {
            System.out.println("Closing connections for mutable request handler");
            try {
                closeWriteableDbConnections();
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

        private synchronized void closeWriteableDbConnections() throws PGEInternalErrorException {
            writeableDb = -1;
            CacheableConnection userC = userConnection;
            CacheableConnection adminC = adminConnection;
            userConnection = null;
            adminConnection = null;
            try {
                if (userC != null) {
                    userC.closeConnection();
                }
            } finally {
                if (adminC != null) {
                    adminC.closeConnection();
                }

            }
        }

        private synchronized int reserveWriteableDb(CacheableConnection managementConnection, int desiredDb) throws PGEUserException, PGEInternalErrorException {
            // Attempt to lock a database we've optimistically selected first. This allows
            // us to initialise all the connections we want simultaneously if it works out
            // (which it generally does).
            System.out.println("Optimistically locking writeable DB with ID: " + desiredDb);
            QueryResponse lockedId = lockWriteableDb(managementConnection, desiredDb);

            if (lockedId == null || lockedId.getSingleValue() == null) {
                System.out.println("Failed optimistic lock, falling back to a general search");
                lockedId = lockWriteableDb(managementConnection, null);
            }

            String value = lockedId == null || lockedId.getSingleValue() == null ? null : lockedId.getSingleValue();

            if (value == null) {
                throw new PGEUserException("PGExercises is overloaded right now: please retry");
            }
            return Integer.parseInt(value);
        }

        private synchronized @Nullable QueryResponse lockWriteableDb(CacheableConnection managementConnection, @Nullable Integer dbOffset) throws PGEInternalErrorException {
            String sql;
            if (dbOffset == null) {
                sql = "SELECT lock_id FROM mgmt.lock_list FOR UPDATE SKIP LOCKED LIMIT 1";
            } else {
                sql = "SELECT lock_id FROM mgmt.lock_list WHERE lock_id = " + dbOffset + " FOR UPDATE SKIP LOCKED";
            }

            try {
                managementConnection.execute("BEGIN");
                return managementConnection.execute(sql);
            } catch (SQLException | PGEUserException e) {
                try {
                    managementConnection.execute("ROLLBACK");
                } catch (Exception e2) {
                    e2.printStackTrace();
                    managementConnection.closeConnection();
                }
                throw new PGEInternalErrorException("Couldn't lock writeable DB. Desired db was: " + dbOffset);
            }
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
