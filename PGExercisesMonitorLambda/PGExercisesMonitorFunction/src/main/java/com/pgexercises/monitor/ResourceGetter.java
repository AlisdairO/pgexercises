package com.pgexercises.monitor;

import org.jetbrains.annotations.NotNull;

import java.io.IOException;
import java.util.Map;

public interface ResourceGetter {
    @NotNull String getResource(@NotNull String uri) throws IOException;
    @NotNull String getResource(@NotNull String uri, Map<String, String> params) throws IOException;
    int getThrottleWaitTimeMs();
}
