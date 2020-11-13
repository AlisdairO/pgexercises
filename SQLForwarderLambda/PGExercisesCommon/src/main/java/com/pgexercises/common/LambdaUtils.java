package com.pgexercises.common;

import com.pgexercises.exceptions.PGEInternalErrorException;

public class LambdaUtils {
    public static String getRequiredEnvVar(String var) throws PGEInternalErrorException {
        String value = System.getenv(var);
        if (value == null) {
            throw new PGEInternalErrorException("Required environment variable '" + var + "' not present");
        }
        return value;
    }
}
