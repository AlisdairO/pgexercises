package com.pgexercises.exceptions;

import org.checkerframework.checker.nullness.qual.Nullable;

public class PGEInternalErrorException extends Exception {
    public PGEInternalErrorException(@Nullable String message) {
        super(message == null ? "" : message);
    }
    public PGEInternalErrorException(@Nullable String message, Exception cause) {
        super(message == null ? "" : message, cause);
    }
}
