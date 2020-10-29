package com.pgexercises.monitor;

import org.apache.commons.lang3.Validate;
import org.checkerframework.checker.nullness.qual.NonNull;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URISyntaxException;
import java.util.Map;
import java.util.TreeMap;

public class ResourceGetterStub implements ResourceGetter {

    Map<String, String> resources = new TreeMap<>();

    @Override
    public @NonNull String getResource(@NonNull String uri) throws IOException {
        return getResource(uri, Map.of());
    }

    @Override
    public @NonNull String getResource(@NonNull String uri, Map<String, String> params) throws IOException {
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

    public void addResource(@NonNull String uri, @NonNull String value) throws URISyntaxException {
        this.addResource(uri, value, Map.of());
    }

    public void addResource(@NonNull String uri, @NonNull String value, Map<String, String> params) throws URISyntaxException {
        Validate.notNull(uri);
        Validate.notNull(value);
        this.resources.put(Utils.buildUri(uri, params).toString(), value);
    }
}
