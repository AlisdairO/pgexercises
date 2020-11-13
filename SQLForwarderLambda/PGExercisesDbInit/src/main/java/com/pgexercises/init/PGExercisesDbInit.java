package com.pgexercises.init;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.pgexercises.common.CacheableConnection;
import com.pgexercises.common.DbEnvInfo;
import com.pgexercises.common.DbInitializer;
import com.pgexercises.common.DbSource;
import com.pgexercises.common.QueryResponse;
import com.pgexercises.exceptions.PGEInternalErrorException;
import com.pgexercises.exceptions.PGEUserException;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.json.simple.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class PGExercisesDbInit implements RequestHandler<Map<String, Object>, Object> {

    private static final String CHECK_IF_INITED =
            "SELECT exists(select schema_name FROM information_schema.schemata WHERE schema_name = 'create_complete');";
    private static final String TAKE_INIT_LOCK =
            "SELECT pg_advisory_lock(0);";
    private static final String SET_USER_PASSWORD =
            "ALTER USER <USER> WITH PASSWORD '<PASSWORD>';";

    @Override
    public Object handleRequest(Map<String, Object> input, Context context) {
        try {
            input.entrySet().forEach(entry->{
                System.out.println("INPUT: " + entry.getKey() + " " + entry.getValue());
            });
            System.out.println("CONTEXT: " + ToStringBuilder.reflectionToString(context));

            String reqType = (String)input.get("RequestType");
            if (reqType != null && !reqType.equalsIgnoreCase("DELETE")) {
                DbEnvInfo envInfo = new DbEnvInfo();
                CacheableConnection dbConnection = new CacheableConnection(new DbSource(
                        envInfo.getJDBCURI(), envInfo.getAdminDbName(), envInfo.getAdminUser(), envInfo.getAdminUserPassword()));
                try {
                    takeLock(dbConnection);
                    if (!isInitialised(dbConnection)) {
                        System.out.println("Need to init from scratch");
                        DbInitializer.initFromScratch(dbConnection, envInfo);
                    } else {
                        System.out.println("Just resetting password");
                        setUserPassword(dbConnection, envInfo);
                    }
                } finally {
                    dbConnection.closeConnection();
                }
            } else {
                System.out.println("Delete request received");
            }
            ackCloudFormation(input, context, true);
            return new Object();
        } catch (Exception e) {
            System.out.println("Couldn't init database: " + e.getMessage());
            try {
                ackCloudFormation(input, context, false);
            } catch (Exception e2) {
                // ignore, we're already failing...
                System.out.println(e2.getMessage());
            }
            throw new RuntimeException("Couldn't init database: " + e.getMessage(), e);
        }
    }

    @SuppressWarnings("unchecked")
    private void ackCloudFormation(Map<String, Object> input, Context context, boolean success) throws IOException, PGEInternalErrorException {
        System.out.println("Responding to CloudFormation with success value: " + success);
        String responseUrl = (String)input.get("ResponseURL");
        if (responseUrl == null) {
            throw new PGEInternalErrorException("Response URL not found");
        }
        System.out.println("ResponseURL: " + responseUrl);

        URL s3 = new URL(responseUrl);
        HttpURLConnection conn = (HttpURLConnection)s3.openConnection();
        conn.setDoInput(true);
        conn.setDoOutput(true);
        conn.setRequestMethod("PUT");
        JSONObject body = new JSONObject();
        body.put("Status", success ? "SUCCESS" : "FAILED");
        body.put("StackId", input.get("StackId"));
        body.put("LogicalResourceId", input.get("LogicalResourceId"));
        body.put("PhysicalResourceId", context.getLogStreamName());
        body.put("RequestId", input.get("RequestId"));

        OutputStreamWriter response = new OutputStreamWriter(conn.getOutputStream(), StandardCharsets.UTF_8);
        String output = body.toJSONString();
        System.out.println("OUTPUT: " + output);
        response.write(output);
        response.close();
        conn.connect();
        BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
        String temp;
        while((temp = in.readLine()) != null){
            System.out.println("OUT: " + temp);
        }
        in.close();
        System.out.println("Response: " + ToStringBuilder.reflectionToString(conn));
    }

    private void takeLock(CacheableConnection dbConnection) throws PGEInternalErrorException, SQLException, PGEUserException {
        System.out.println("Taking lock");
        dbConnection.execute(TAKE_INIT_LOCK);
    }

    private boolean isInitialised(CacheableConnection dbConnection) throws PGEUserException, SQLException, PGEInternalErrorException {
        System.out.println("Checking initialisation status");
        QueryResponse queryResponse = dbConnection.execute(CHECK_IF_INITED);
        if (queryResponse == null) {
            return false;
        }
        System.out.println("INIT STATUS: " + queryResponse.toJson().toJSONString());
        List<String[]> values = queryResponse.getValues();
        return values.size() == 1 && values.get(0).length == 1 && values.get(0)[0].equals("1");
    }

    private void setUserPassword(CacheableConnection dbConnection, DbEnvInfo envInfo) throws PGEInternalErrorException {
        dbConnection.executeUpdateInternal(envInfo.replaceEnvInfoInSql(SET_USER_PASSWORD));
    }
}
