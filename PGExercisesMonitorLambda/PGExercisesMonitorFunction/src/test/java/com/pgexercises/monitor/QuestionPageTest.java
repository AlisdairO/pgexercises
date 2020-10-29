package com.pgexercises.monitor;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.pgexercises.monitor.serialization.QueryResults;
import com.pgexercises.monitor.serialization.ResultsTable;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;

import java.net.URISyntaxException;
import java.util.*;

@SuppressWarnings("initialization.fields.uninitialized")
public class QuestionPageTest {
    private static final ObjectMapper MAPPER = new ObjectMapper();
    private static final String DEFAULT_QUERY = "select max(joindate) as latest\n" +
            "from cd.members";
    private ResourceGetterStub resourceGetter;

    @Rule
    public ExpectedException expectedEx = ExpectedException.none();

    @Before
    public void setup() {
        resourceGetter = new ResourceGetterStub();
    }

    @Test
    public void testGoldenPath() throws Exception {
        basicTest(DEFAULT_QUERY,
                "0",
                "0",
                "",
                Monitor.SQL_ENDPOINT,
                List.of(List.of("row1value1", "row1value2"),
                        List.of("row2value1", "row2value2")),
                List.of(List.of("row1value1", "row1value2"),
                        List.of("row2value1", "row2value2"))
        );
    }

    @Test
    public void testResultsMismatch() throws Exception {
        expectedEx.expectMessage("Data didn't match. Failing.");
        basicTest(DEFAULT_QUERY,
                "0",
                "0",
                "",
                Monitor.SQL_ENDPOINT,
                List.of(List.of("row2value1", "row2value2")),
                List.of(List.of("row1value1", "row1value2"),
                        List.of("row2value1", "row2value2"))
        );
    }

    @Test
    public void testSortCorrect() throws Exception {
        basicTest(DEFAULT_QUERY,
                "0",
                "0",
                "",
                Monitor.SQL_ENDPOINT,
                List.of(List.of("row2value1", "row2value2"),
                        List.of("row1value1", "row1value2")),
                List.of(List.of("row1value1", "row1value2"),
                        List.of("row2value1", "row2value2"))
        );
    }

    @Test
    public void testSortIncorrect() throws Exception {
        expectedEx.expectMessage("Data didn't match. Failing.");
        basicTest(DEFAULT_QUERY,
                "0",
                "1",
                "",
                Monitor.SQL_ENDPOINT,
                List.of(List.of("row2value1", "row2value2"),
                        List.of("row1value1", "row1value2")),
                List.of(List.of("row1value1", "row1value2"),
                        List.of("row2value1", "row2value2"))
        );
    }

    @Test
    public void testNotFound() throws Exception {
        expectedEx.expectMessage("Not found: ?query=select+ma");
        basicTest(DEFAULT_QUERY,
                "0",
                "0",
                "",
                "",
                List.of(List.of("row1value1", "row1value2"),
                        List.of("row2value1", "row2value2")),
                List.of(List.of("row1value1", "row1value2"),
                        List.of("row2value1", "row2value2"))
        );
    }

    @Test
    public void testIsModifiable() throws Exception {
        basicTest(DEFAULT_QUERY,
                "1",
                "1",
                "facilities",
                Monitor.SQL_ENDPOINT,
                List.of(List.of("row1value1", "row1value2"),
                        List.of("row2value1", "row2value2")),
                List.of(List.of("row1value1", "row1value2"),
                        List.of("row2value1", "row2value2"))
                );
    }

    private void basicTest(String query,
                           String isModifiable,
                           String sorted,
                           String tableToReturn,
                           String sqlEndpoint,
                           List<List<String>> expectedResults,
                           List<List<String>> actualResults
                           ) throws Exception {
        resourceGetter.addResource(getExpectedQueryURI(query, isModifiable, tableToReturn), MAPPER.writeValueAsString(buildQueryResults(actualResults)));
        String pageData = createPage(query, isModifiable, sorted, tableToReturn, expectedResults);
        QuestionPage page = new QuestionPage(pageData);
        page.validate(new TestLogger(), resourceGetter, sqlEndpoint);
    }

    private String createPage(String query, String isModifiable, String sorted, String tableToReturn, List<List<String>> expectedResults) throws JsonProcessingException {
        String results = new ObjectMapper().writeValueAsString(expectedResults);
        return String.format("<pre id=\"querydiv\" class=\"answerdiv prettyprint lang-sql\">%s" +
                "</pre>" +
                "<script>\n" +
                "var App = {};\n" +
                "App.sorted = %s;\n" +
                "App.pageID = \"48B782DB-FAA6-4124-82AF-4E2AFF1044B5\";\n" +
                "App.writeable = %s;\n" +
                "App.tableToReturn = \"%s\";\n" +
                "App.jsonResults = sortJSONResults(%s);\n" +
                "</script>\n", query, sorted, isModifiable, tableToReturn, results);
    }

    private String getExpectedQueryURI(String query, String isModifiable, String tableToReturn) throws URISyntaxException {
        SortedMap<String, String> params = new TreeMap<>(Map.of(
                "query", query,
                "tableToReturn", tableToReturn,
                "writeable", isModifiable
        ));
        return Utils.buildUri(Monitor.SQL_ENDPOINT, params).toString();
    }

    private QueryResults buildQueryResults(List<List<String>> results) {
        List<String> headers = new ArrayList<>();
        if (results.size() > 0) {
            for (int i = 0; i < results.get(0).size(); i++) {
                headers.add("header" + i);
            }
        }
        return new QueryResults(headers, new ResultsTable(results));
    }
}
