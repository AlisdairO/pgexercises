package com.pgexercises.monitor;

import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.pgexercises.monitor.serialization.QueryResults;
import com.pgexercises.monitor.serialization.ResultsTable;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.Validate;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.jetbrains.annotations.NotNull;

import java.io.IOException;
import java.util.TreeMap;
import java.util.regex.Pattern;

public class QuestionPage {
    private static final Pattern SUGGESTED_SQL_FINDER_PATTER = Pattern.compile("<pre id=\"querydiv\" class=\"answerdiv prettyprint lang-sql\">(.*?)</pre>", Pattern.DOTALL);
    private static final Pattern EXPECTED_RESULTS_FINDER_PATTERN = Pattern.compile("App\\.jsonResults = sortJSONResults\\((.*?)\\);", Pattern.DOTALL);
    private static final Pattern IS_MODIFYING_FINDER_PATTERN = Pattern.compile("App\\.writeable = (\\d);", Pattern.DOTALL);
    private static final Pattern TABLES_TO_RETURN_FINDER_PATTERN = Pattern.compile("App\\.tableToReturn = \"(.*?)\";", Pattern.DOTALL);
    private static final Pattern IS_SORTED_FINDER_PATTERN = Pattern.compile("App\\.sorted = (\\d);", Pattern.DOTALL);
    private static final ObjectMapper MAPPER = new ObjectMapper();

    private final boolean isModifyingSolution;
    private final ResultsTable expectedResults;
    private final String suggestedSolution;
    private final String tableToReturn;
    private final boolean isSorted;

    public QuestionPage(@NotNull String pageData) throws JsonProcessingException {
        Validate.notNull(pageData);
        isModifyingSolution = findIsModifyingSolution(pageData);
        expectedResults = MAPPER.readValue(findExpectedResults(pageData), ResultsTable.class);
        suggestedSolution = findSuggestedSolution(pageData);
        tableToReturn = findTableToReturn(pageData);
        isSorted = findIsSorted(pageData);
    }

    private boolean findIsSorted(String pageContent) {
        return Utils.getSingleMatchFromPage(pageContent, IS_SORTED_FINDER_PATTERN).equals("1");
    }

    private String findTableToReturn(String pageContent) {
        return Utils.getSingleMatchFromPage(pageContent, TABLES_TO_RETURN_FINDER_PATTERN);
    }

    private boolean findIsModifyingSolution(String pageContent) {
        return Utils.getSingleMatchFromPage(pageContent, IS_MODIFYING_FINDER_PATTERN).equals("1");
    }

    private String findExpectedResults(@NotNull String pageContent) {
        return Utils.getSingleMatchFromPage(pageContent, EXPECTED_RESULTS_FINDER_PATTERN);
    }

    private String findSuggestedSolution(@NotNull String pageContent) {
        return Utils.getSingleMatchFromPage(pageContent, SUGGESTED_SQL_FINDER_PATTER);
    }

    public void validate(@NotNull LambdaLogger logger, @NotNull ResourceGetter resourceGetter, String endpointLocation) throws IOException {
        Validate.notNull(logger);
        Validate.notNull(resourceGetter);
        logger.log(this.toString() + "\n");
        QueryResults actualResults = queryActualResults(logger, resourceGetter, endpointLocation);
        if (!actualResults.getValues().matches(expectedResults, isSorted)) {
            logger.log(String.format("Data didn't match.%n  Page data: [%s]%n  Actual: [%s]", this.toString(), actualResults.getValues()));
            throw new RuntimeException("Data didn't match. Failing.");
        }
    }

    private QueryResults queryActualResults(@NotNull LambdaLogger logger, @NotNull ResourceGetter resourceGetter, String endpointLocation) throws IOException {
        TreeMap<String, String> params = new TreeMap<>();
        params.put("query", suggestedSolution);
        params.put("writeable", isModifyingSolution ? "1" : "0");
        params.put("tableToReturn", tableToReturn);
        logger.log(String.format("Hitting URI: [%s] with params [%s]%n", endpointLocation, StringUtils.join(params)));
        return MAPPER.readValue(resourceGetter.getResource(endpointLocation, params), QueryResults.class);
    }

    @Override
    public @NotNull String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
