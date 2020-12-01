package com.pgexercises.sqlforwarder;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import com.pgexercises.common.DbEnvInfo;
import com.pgexercises.common.QueryResponse;
import com.pgexercises.exceptions.PGEInternalErrorException;
import com.pgexercises.exceptions.PGEUserException;
import com.pgexercises.sqlforwarder.requesthandler.RequestHandlerManager;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

/**
 * Handler for requests to Lambda function.
 */
public class SQLForwarder implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {
    // RequestHandlerManager is statically initialized because Lambda performance: during the init period,
    // Lambdas get larger CPU shares. The AWS SDK and JDBC libs have nontrivial initialisation costs, and
    // initialising here makes a LARGE difference in cold start time.
    //
    // Arguably I ought to write all this stuff in something quick to init like Rust. More likely
    // is that I'll build a Graal native-image version :-)
    private static volatile RequestHandlerManager requestHandlerManager;
    static {
        try {
            requestHandlerManager = init();
        } catch (Exception e) {
            throw new RuntimeException("Initialisation error: " + e.getMessage(), e);
        }
    }

    public APIGatewayProxyResponseEvent handleRequest(final APIGatewayProxyRequestEvent input, final Context context) {
        Map<String, String> headers = new HashMap<>();
        headers.put("Content-Type", "application/json");
        headers.put("X-Custom-Header", "application/json");

        APIGatewayProxyResponseEvent response = new APIGatewayProxyResponseEvent().withHeaders(headers);

        try {
            RequestData reqData = new RequestData(input.getQueryStringParameters());
            System.out.println("DEBUG: REQUEST: " + reqData.toString());

            QueryResponse queryResponse = requestHandlerManager.handleRequest(reqData);
            String body = queryResponse == null ? "" : queryResponse.toJson().toJSONString();
            return response.withStatusCode(200).withBody(body);

        } catch (PGEUserException e) {
            System.out.println("INFO: User error: " + e.getMessage());
            return response
                    .withStatusCode(400)
                    .withBody(e.getMessage() == null ? "" : e.getMessage());
        } catch (PGEInternalErrorException e) {
            System.out.println("ERROR: " + e.getMessage());
            throw new RuntimeException(e);
        }
    }

/*    public static void printTime(String label) {
        System.out.println(label + ": "  + (System.currentTimeMillis() - time));
    }*/

    private static RequestHandlerManager init() throws PGEInternalErrorException, SQLException, PGEUserException {
        if (requestHandlerManager == null) {
            requestHandlerManager = new RequestHandlerManager(new DbEnvInfo());
        }
        return requestHandlerManager;
    }


}