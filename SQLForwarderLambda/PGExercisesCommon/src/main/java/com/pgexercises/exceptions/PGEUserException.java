package com.pgexercises.exceptions;

import org.checkerframework.checker.nullness.qual.Nullable;

public class PGEUserException extends Exception {
    public PGEUserException(@Nullable String message) {
        super(message == null ? "" : message);
    }
}
