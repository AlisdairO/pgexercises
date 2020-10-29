package com.pgexercises.monitor;

import org.apache.commons.lang3.Validate;
import org.apache.http.client.utils.URIBuilder;
import org.checkerframework.checker.nullness.qual.NonNull;
import org.checkerframework.framework.qual.DefaultQualifier;
import org.checkerframework.framework.qual.TypeUseLocation;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@DefaultQualifier(value = NonNull.class, locations = TypeUseLocation.LOCAL_VARIABLE)
public class Utils {
    public static String getSingleMatchFromPage(@NonNull String basePageContents, @NonNull Pattern pattern) {
        Validate.notNull(basePageContents);
        Validate.notNull(pattern);
        List<String> expectedResults = getMatchesFromPage(basePageContents, pattern, "");
        if (expectedResults.size() != 1) {
            throw new RuntimeException("Expected match size of 1, got " + expectedResults.size() + " when matching pattern " + pattern.pattern());
        }
        String match = expectedResults.get(0);
        if (match == null) {
            throw new RuntimeException("Expected non-null match when matching pattern " + pattern.pattern());
        }
        return match;
    }

    public static List<String> getMatchesFromPage(@NonNull String basePageContents, @NonNull Pattern pattern, @NonNull String prefixToAdd) {
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

    public static URI buildUri(@NonNull String uri, @NonNull Map<String, String> params) throws URISyntaxException {
        Validate.notNull(params);
        Validate.notNull(uri);
        URIBuilder uriBuilder = new URIBuilder(uri);
        params.entrySet().stream().forEach(e -> uriBuilder.addParameter(e.getKey(), e.getValue()));
        return uriBuilder.build();
    }
}
