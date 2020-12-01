package com.pgexercises.sqlforwarder.requesthandler;

import com.pgexercises.common.DbEnvInfo;
import com.pgexercises.common.DbSource;
import com.pgexercises.common.QueryResponse;
import com.pgexercises.exceptions.PGEInternalErrorException;
import com.pgexercises.exceptions.PGEUserException;
import com.pgexercises.sqlforwarder.RequestData;
import org.checkerframework.checker.nullness.qual.Nullable;

public class RequestHandlerManager {
    private final MutableOpRequestHandler mutableOpRequestHandler;
    private final ImmutableOpRequestHandler immutableOpRequestHandler;

    public RequestHandlerManager(DbEnvInfo envInfo) throws PGEUserException, PGEInternalErrorException {
        DbSource managementSource = new DbSource(envInfo.getJDBCURI(), envInfo.getAdminDbName(), envInfo.getAdminUser(), envInfo.getAdminUserPassword());
        DbSource immutableUserSource = new DbSource(envInfo.getJDBCURI(), envInfo.getBaseDbName(), envInfo.getUnprivilegedUser(), envInfo.getUnprivilegedUserPassword());
        DbSource mutableUserSource = new DbSource(envInfo.getJDBCURI(), envInfo.getBaseDbName(), envInfo.getUnprivilegedUser(), envInfo.getUnprivilegedUserPassword());
        DbSource mutableAdminSource = new DbSource(envInfo.getJDBCURI(), envInfo.getBaseDbName(), envInfo.getAdminUser(), envInfo.getAdminUserPassword());

        // TODO switch to request-on-demand, allows us to determine the writer data source correctly when needed
        mutableOpRequestHandler = new MutableOpRequestHandler(mutableUserSource, mutableAdminSource, managementSource, envInfo);
        immutableOpRequestHandler = new ImmutableOpRequestHandler(immutableUserSource);
        mutableOpRequestHandler.initPreWarm();
        // pre-warms the connection for immutable queries, which are the overwhelming majority
        immutableOpRequestHandler.performQuery(new RequestData("select 1"));
        mutableOpRequestHandler.waitOnInit();
    }

    public synchronized @Nullable QueryResponse handleRequest(RequestData reqData) throws PGEInternalErrorException, PGEUserException {
        RequestHandler handler = reqData.isWriteable() ? mutableOpRequestHandler : immutableOpRequestHandler;
        try {
            handler.preCheck();
            return handler.performQuery(reqData);
        } finally {
            handler.cleanupAfterQuery();
        }
    }
}
