package com.pgexercises.monitor;

import org.apache.commons.lang3.Validate;
import org.jetbrains.annotations.NotNull;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URISyntaxException;
import java.util.Map;
import java.util.TreeMap;

public class ResourceGetterStub implements ResourceGetter {

    Map<String, String> resources = new TreeMap<>();

    @Override
    public @NotNull String getResource(@NotNull String uri) throws IOException {
        return getResource(uri, Map.of());
    }

    @Override
    public @NotNull String getResource(@NotNull String uri, Map<String, String> params) throws IOException {
        Validate.notNull(uri);
        try {
            uri = Utils.buildUri(uri, params).toString();
        } catch (URISyntaxException e) {
            throw new RuntimeException("Bad URI in test code");
        }
        if (!resources.containsKey(uri)) {
            throw new FileNotFoundException("Not found: " + uri);
        }
        return resources.get(uri);
    }

    @Override
    public int getThrottleWaitTimeMs() {
        return 0;
    }

    public void addResource(@NotNull String uri, @NotNull String value) throws URISyntaxException {
        this.addResource(uri, value, Map.of());
    }

    public void addResource(@NotNull String uri, @NotNull String value, Map<String, String> params) throws URISyntaxException {
        Validate.notNull(uri);
        Validate.notNull(value);
        this.resources.put(Utils.buildUri(uri, params).toString(), value);
    }
}
