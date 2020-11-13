package com.pgexercises.sqlforwarder.requesthandler;

import com.pgexercises.common.QueryResponse;
import com.pgexercises.exceptions.PGEInternalErrorException;
import com.pgexercises.exceptions.PGEUserException;
import com.pgexercises.sqlforwarder.RequestData;
import org.checkerframework.checker.nullness.qual.Nullable;

public interface RequestHandler {
    @Nullable QueryResponse performQuery(RequestData requestData) throws PGEInternalErrorException, PGEUserException;

    void cleanupAfterQuery() throws PGEInternalErrorException;

    void preCheck() throws PGEInternalErrorException, PGEUserException;
}
