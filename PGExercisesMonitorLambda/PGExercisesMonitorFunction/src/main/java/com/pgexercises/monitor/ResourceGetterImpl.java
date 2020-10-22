package com.pgexercises.monitor;

import org.apache.commons.lang3.Validate;
import org.jetbrains.annotations.NotNull;

import java.io.IOException;
import java.net.URISyntaxException;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.Collections;
import java.util.Map;

public class ResourceGetterImpl implements ResourceGetter {
    private final HttpClient httpClient;

    public ResourceGetterImpl() {
        httpClient = HttpClient.newBuilder()
                .followRedirects(HttpClient.Redirect.NORMAL)
                .build();
    }

    @Override
    public @NotNull String getResource(@NotNull String uri) throws IOException {
        Validate.notNull(uri);
        return getResource(uri, Collections.emptyMap());
    }

    @Override
    public @NotNull String getResource(@NotNull String uri, @NotNull Map<String, String> params) throws IOException {
        Validate.notNull(uri);
        Validate.notNull(params);

        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(Utils.buildUri(uri, params))
                    .build();
            HttpResponse<String> response =
                    httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() >= 400) {
                throw new RuntimeException("Error code received: " + response.statusCode());
            }

            return response.body();
        } catch (URISyntaxException e) {
            throw new RuntimeException("Couldn't build URI: " + uri, e);
        } catch (InterruptedException e) {
            throw new RuntimeException("Interrupted, exiting");
        }
    }

    @Override
    public int getThrottleWaitTimeMs() {
        return 500;
    }
}
