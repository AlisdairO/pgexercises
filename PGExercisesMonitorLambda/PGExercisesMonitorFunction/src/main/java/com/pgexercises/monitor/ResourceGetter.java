package com.pgexercises.monitor;

import org.checkerframework.checker.nullness.qual.NonNull;

import java.io.IOException;
import java.util.Map;

public interface ResourceGetter {
    @NonNull String getResource(@NonNull String uri) throws IOException;
    @NonNull String getResource(@NonNull String uri, Map<String, String> params) throws IOException;
    int getThrottleWaitTimeMs();
}
