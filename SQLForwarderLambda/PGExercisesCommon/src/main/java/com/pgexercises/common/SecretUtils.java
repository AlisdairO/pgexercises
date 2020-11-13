package com.pgexercises.common;

import com.pgexercises.exceptions.PGEInternalErrorException;
import org.json.simple.JSONObject;
import org.json.simple.JSONValue;
import software.amazon.awssdk.auth.credentials.EnvironmentVariableCredentialsProvider;
import software.amazon.awssdk.http.urlconnection.UrlConnectionHttpClient;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
import software.amazon.awssdk.services.secretsmanager.model.DecryptionFailureException;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueResponse;
import software.amazon.awssdk.services.secretsmanager.model.InternalServiceErrorException;
import software.amazon.awssdk.services.secretsmanager.model.InvalidParameterException;

// TODO: Would be nice to refactor the printlns to a logger for common code: Lambda sends System.out to CWL,
// so this works but it's a little nasty...
public class SecretUtils {
    public static String getPasswordForSecretId(String secretId, Region region) throws PGEInternalErrorException {
        System.out.println("DEBUG: getting secret" + secretId);
        SecretsManagerClient client = SecretsManagerClient.builder()
                .region(region)
                .credentialsProvider(EnvironmentVariableCredentialsProvider.create())
                .httpClient(UrlConnectionHttpClient.builder().build())
                .build();
        GetSecretValueResponse response;
        try {
            response = client.getSecretValue(GetSecretValueRequest.builder().secretId(secretId).build());
            String secret = response.secretString();
            if(secret == null) {
                throw new PGEInternalErrorException("Secret " + secretId + " value is null");
            }
            JSONObject secretJson = (JSONObject) JSONValue.parse(secret);
            String password = (String)secretJson.get("password");
            if (password == null) {
                throw new PGEInternalErrorException("Couldn't find password for secret");
            }
            System.out.println("got secret");
            return password;

        } catch(DecryptionFailureException | InternalServiceErrorException | InvalidParameterException e) {
            throw new PGEInternalErrorException("Error requesting secret: " + secretId + ", error was: " + e.getMessage(), e);
        }
    }
}
