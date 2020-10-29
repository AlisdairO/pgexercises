package com.pgexercises.monitor;

import com.amazonaws.services.lambda.runtime.*;

import java.util.Map;

public class TestContext implements Context{

    public TestContext() {}
    public String getAwsRequestId(){
        return "495b12a8-xmpl-4eca-8168-160484189f99";
    }
    public String getLogGroupName(){
        return "/aws/lambda/my-function";
    }
    public String getLogStreamName(){
        return "2020/02/26/[$LATEST]704f8dxmpla04097b9134246b8438f1a";
    }
    public String getFunctionName(){
        return "my-function";
    }
    public String getFunctionVersion(){
        return "$LATEST";
    }
    public String getInvokedFunctionArn(){
        return "arn:aws:lambda:us-east-2:123456789012:function:my-function";
    }
    public CognitoIdentity getIdentity(){
        return new CognitoIdentity() {
            @Override
            public String getIdentityId() {
                return "test";
            }

            @Override
            public String getIdentityPoolId() {
                return "test2";
            }
        };
    }
    public ClientContext getClientContext(){
        return new ClientContext() {
            @Override
            public Client getClient() {
                return new Client() {
                    @Override
                    public String getInstallationId() {
                        return "";
                    }

                    @Override
                    public String getAppTitle() {
                        return "";
                    }

                    @Override
                    public String getAppVersionName() {
                        return "";
                    }

                    @Override
                    public String getAppVersionCode() {
                        return "";
                    }

                    @Override
                    public String getAppPackageName() {
                        return "";
                    }
                };
            }

            @Override
            public Map<String, String> getCustom() {
                return Map.of();
            }

            @Override
            public Map<String, String> getEnvironment() {
                return Map.of();
            }
        };
    }
    public int getRemainingTimeInMillis(){
        return 300000;
    }
    public int getMemoryLimitInMB(){
        return 512;
    }
    public LambdaLogger getLogger(){
        return new TestLogger();
    }

}