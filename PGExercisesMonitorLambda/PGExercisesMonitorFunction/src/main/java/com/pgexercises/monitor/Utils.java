package com.pgexercises.monitor;

import org.apache.commons.lang3.Validate;
import org.apache.http.client.utils.URIBuilder;
import org.jetbrains.annotations.NotNull;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Utils {
    public static String getSingleMatchFromPage(@NotNull String basePageContents, @NotNull Pattern pattern) {
        Validate.notNull(basePageContents);
        Validate.notNull(pattern);
        List<String> expectedResults = getMatchesFromPage(basePageContents, pattern, "");
        if (expectedResults.size() != 1) {
            throw new RuntimeException("Expected match size of 1, got " + expectedResults.size() + " when matching pattern " + pattern.pattern());
        }
        return expectedResults.get(0);
    }

    public static List<String> getMatchesFromPage(@NotNull String basePageContents, @NotNull Pattern pattern, @NotNull String prefixToAdd) {
        Validate.notNull(basePageContents);
        Validate.notNull(pattern);
        Validate.notNull(prefixToAdd);
        List<String> matches = new ArrayList<>();
        Matcher matcher = pattern.matcher(basePageContents);
        while(matcher.find()) {
            matches.add(prefixToAdd + matcher.group(1));
        }
        return matches;
    }

    public static URI buildUri(@NotNull String uri, @NotNull Map<String, String> params) throws URISyntaxException {
        Validate.notNull(params);
        Validate.notNull(uri);
        URIBuilder uriBuilder = new URIBuilder(uri);
        params.entrySet().stream().forEach(e -> uriBuilder.addParameter(e.getKey(), e.getValue()));
        return uriBuilder.build();
    }
}
