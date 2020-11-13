package com.pgexercises.sqlforwarder.requesthandler;

import com.pgexercises.common.CacheableConnection;
import com.pgexercises.common.DbSource;
import com.pgexercises.common.QueryResponse;
import com.pgexercises.exceptions.PGEInternalErrorException;
import com.pgexercises.exceptions.PGEUserException;
import com.pgexercises.sqlforwarder.RequestData;
import org.checkerframework.checker.nullness.qual.Nullable;

import java.sql.SQLException;

public class ImmutableOpRequestHandler implements RequestHandler {
    private final CacheableConnection connection;

    public ImmutableOpRequestHandler(DbSource readableDbSource) {
        connection = new CacheableConnection(readableDbSource);
    }

    @Override
    public synchronized @Nullable QueryResponse performQuery(RequestData requestData) throws PGEInternalErrorException, PGEUserException {
        try {
            return connection.execute(requestData.getQuery());
        } catch (SQLException e) {
            //TODO this is a bit crap - still the possibility of an internal error
            //after all.  Inspect the PSQLState for 400 vs 500 indicator purposes!
            throw new PGEUserException(e.getMessage());
        }
    }

    @Override
    public synchronized void cleanupAfterQuery() throws PGEInternalErrorException {
        connection.resetConnectionForPooling();
    }

    @Override
    public synchronized void preCheck() throws PGEInternalErrorException {
        try {
            connection.execute("select 1");
        } catch (Exception e) {
            connection.closeConnection();
        }
    }
}
