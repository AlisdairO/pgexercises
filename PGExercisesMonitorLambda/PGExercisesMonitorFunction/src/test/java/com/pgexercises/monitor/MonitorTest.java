package com.pgexercises.monitor;

import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;

import java.net.URISyntaxException;

import static org.junit.Assert.assertEquals;

@SuppressWarnings("initialization.fields.uninitialized")
public class MonitorTest {
    private static final String[] CATEGORY_PAGES = new String[] {"basic", "joins", "updates", "aggregates", "date", "string", "recursive"};
    private static final String[] QUESTION_PAGES = new String[] {"selectall.html","selectspecific.html","where.html","where2.html","where3.html","where4.html","classify.html","date.html","unique.html","union.html","agg.html","agg2.html"};

    private Monitor monitor;
    private ResourceGetterStub resourceGetter;
    private TestContext context;
    @Rule
    public ExpectedException expectedEx = ExpectedException.none();

    @Before
    public void setup() {
        resourceGetter = new ResourceGetterStub();
        monitor = new Monitor(resourceGetter);
        context = new TestContext();
    }

    @Test
    public void staticPagesMissing() throws Exception {
        expectedEx.expectMessage("Not found: https://pgexercises.com/gettingstarted.html");
        APIGatewayProxyResponseEvent result = monitor.handleRequest(null, context);
    }

    @Test
    public void indexPageMissing() throws Exception {
        expectedEx.expectMessage("Not found: https://pgexercises.com");
        addBasicStaticPages();
        APIGatewayProxyResponseEvent result = monitor.handleRequest(null, context);
    }

    @Test
    public void indexPageLackingContent() throws Exception {
        expectedEx.expectMessage("Didn't find enough category page URIs");
        addBasicStaticPages();
        addIndexPageContent("bar");
        APIGatewayProxyResponseEvent result = monitor.handleRequest(null, context);
    }

    @Test
    public void categoryPageNotFound() throws Exception {
        expectedEx.expectMessage("Not found: https://pgexercises.com/questions/");
        addBasicStaticPages();
        addIndexPageContent(TestUtils.getResource("index.html"));
        APIGatewayProxyResponseEvent result = monitor.handleRequest(null, context);
        assertEquals(result.getStatusCode().intValue(), 200);
    }

    @Test
    public void notEnoughCategoryPages() throws Exception {
        expectedEx.expectMessage("Didn't find enough category page URIs");
        addBasicStaticPages();
        addIndexPageContent(TestUtils.getResource("index-toofewcategories.html"));
        APIGatewayProxyResponseEvent result = monitor.handleRequest(null, context);
        assertEquals(result.getStatusCode().intValue(), 200);
    }

    @Test
    public void badCategoryPageContent() throws Exception {
        expectedEx.expectMessage("Didn't find enough question page URIs");
        addBasicStaticPages();
        addIndexPageContent(TestUtils.getResource("index.html"));
        addCategoryPageContent("baz");
        APIGatewayProxyResponseEvent result = monitor.handleRequest(null, context);
        assertEquals(result.getStatusCode().intValue(), 200);
    }

    @Test
    public void queryEndpointNotFound() throws Exception {
        expectedEx.expectMessage("Not found: https://pgexercises.com/SQLForwarder/SQLForwarder?query");
        addBasicStaticPages();
        addIndexPageContent(TestUtils.getResource("index.html"));
        addCategoryPageContent(TestUtils.getResource("basic-category-good.html"));
        addQuestionPageContent(TestUtils.getResource("basic-question-good.html"));
        APIGatewayProxyResponseEvent result = monitor.handleRequest(null, context);
        assertEquals(result.getStatusCode().intValue(), 200);
    }

    @Test
    public void dataDoesntMatch() throws Exception {
        expectedEx.expectMessage("Data didn't match");
        addBasicStaticPages();
        addIndexPageContent(TestUtils.getResource("index.html"));
        addCategoryPageContent(TestUtils.getResource("basic-category-good.html"));
        addQuestionPageContent(TestUtils.getResource("basic-question-good.html"));
        addForwarderResponse(TestUtils.getResource("basic-question-sqlforwarder-response-bad.json"));
        APIGatewayProxyResponseEvent result = monitor.handleRequest(null, context);
        assertEquals(result.getStatusCode().intValue(), 200);
    }

    @Test
    public void goldenPath() throws Exception {
        addBasicStaticPages();
        addIndexPageContent(TestUtils.getResource("index.html"));
        addCategoryPageContent(TestUtils.getResource("basic-category-good.html"));
        addQuestionPageContent(TestUtils.getResource("basic-question-good.html"));
        addForwarderResponse(TestUtils.getResource("basic-question-sqlforwarder-response-good.json"));
        APIGatewayProxyResponseEvent result = monitor.handleRequest(null, context);
        assertEquals(result.getStatusCode().intValue(), 200);
    }

    private void addForwarderResponse(String content) throws URISyntaxException {
        resourceGetter.addResource("https://pgexercises.com/SQLForwarder/SQLForwarder?query=%0Aselect+*+from+cd.facilities%3B++++++++++&tableToReturn=&writeable=0", content);
    }

    private void addCategoryPageContent(String content) throws URISyntaxException {
        for (String category : CATEGORY_PAGES) {
            resourceGetter.addResource(Monitor.BASE_PAGE_URI + "/questions/" + category + "/", content);
        }
    }

    private void addQuestionPageContent(String content) throws URISyntaxException {
        for (String category : CATEGORY_PAGES) {
            for (String question : QUESTION_PAGES) {
                resourceGetter.addResource(Monitor.BASE_PAGE_URI + "/questions/" + category + "//" + question, content);
            }
        }
    }

    private void addBasicStaticPages() throws URISyntaxException {
        for (String page : Monitor.STATIC_PAGES) {
            resourceGetter.addResource(Monitor.BASE_PAGE_URI + "/" + page, "foo");
        }
    }

    private void addIndexPageContent(String content) throws URISyntaxException {
        resourceGetter.addResource(Monitor.BASE_PAGE_URI, content);
    }

}
