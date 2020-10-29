package com.pgexercises.monitor;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import org.apache.commons.lang3.Validate;
import org.checkerframework.checker.nullness.qual.NonNull;
import org.checkerframework.checker.nullness.qual.Nullable;
import org.checkerframework.com.google.common.annotations.VisibleForTesting;
import org.checkerframework.framework.qual.DefaultQualifier;
import org.checkerframework.framework.qual.TypeUseLocation;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.regex.Pattern;

/**
 * Main monitor class for PGExercises. Loads up the website, iterates through the
 * pages in the site, and on the question pages it tries out the queries and compares
 * with the expected result.
 *
 * Notes:
 * * We just throw bare RuntimeExceptions here when anything goes wrong. This
 * is not my preferred style but this project is essentially just a monitoring script,
 * so I'm not excessively worried about style or code-scalability.
 * * Currently we parse the HTML via some janky regexes, which is unreliable in the case
 * that the site changes in some nontrivial fashion. At some point the build scripts should
 * arguably just upload a list of URLs we want to check to an S3 bucket somewhere. For now
 * this is good enough because I basically never change the template :-). The current approach
 * does have the nice side effect of actually working like a user, meaning we actually check
 * the navigation process/links are valid. I'll change this approach if it causes problems
 * in real-world usage.
 */
@DefaultQualifier(value = NonNull.class, locations = TypeUseLocation.LOCAL_VARIABLE)
public class Monitor implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {

    // TODO put this in some config
    @VisibleForTesting
    static final String BASE_PAGE_URI = "https://pgexercises.com";
    @VisibleForTesting static final String SQL_ENDPOINT = BASE_PAGE_URI + "/SQLForwarder/SQLForwarder";
    @VisibleForTesting static final String[] STATIC_PAGES = new String[] {"gettingstarted.html", "about.html", "options.html"};

    private static final Pattern CATEGORY_PAGE_FINDER_PATTERN = Pattern.compile("<li><a href=\"(questions/[^\"]*)\"");
    private static final Pattern QUESTION_PAGE_FINDER_PATTERN = Pattern.compile("<li><span class=\"listingitem\"><a class=\"listlink\" href='([^']*)'");

    private final ResourceGetter resourceGetter;

    public Monitor() {
        this(new ResourceGetterImpl());
    }

    public Monitor(@NonNull ResourceGetter resourceGetter) {
        Validate.notNull(resourceGetter);
        this.resourceGetter = resourceGetter;
    }

    public APIGatewayProxyResponseEvent handleRequest(final @Nullable APIGatewayProxyRequestEvent input, final @NonNull Context context) {
        Validate.notNull(context);
        LambdaLogger logger = context.getLogger();

        Map<String, String> headers = new TreeMap<>();

        APIGatewayProxyResponseEvent response = new APIGatewayProxyResponseEvent()
                .withHeaders(headers);

        try {
            checkStaticPages(logger);
            checkGeneratedPages(logger);
            return response.withStatusCode(200);
        } catch (Exception e) {
            logger.log("ERROR: issue when monitoring pgexercises\n");
            // Throwing an exception through to the Lambda runtime will give us a stack trace etc in CloudWatch
            throw new RuntimeException(e);
        }
    }

    private void checkGeneratedPages(@NonNull LambdaLogger logger) throws IOException {
        String basePageContents = getPageContents(BASE_PAGE_URI, logger);
        List<String> categoryPageURIs = Utils.getMatchesFromPage(basePageContents, CATEGORY_PAGE_FINDER_PATTERN, BASE_PAGE_URI + "/");

        if (categoryPageURIs.size() < 5) {
            logger.log("Didn't find enough category page URIs. URIs found: [" + String.join(",", categoryPageURIs) + "]\n");
            throw new RuntimeException("Didn't find enough category page URIs: something has gone wrong\n");
        }

        for (String page : categoryPageURIs) {
            if(Thread.interrupted()) {
                logger.log("Interrupted, exiting\n");
                return;
            }
            checkCategoryPage(page, logger);
        }
    }

    private void checkCategoryPage(@NonNull String categoryPageURI, @NonNull LambdaLogger logger) throws IOException {
        try {
            String categoryPageContents = getPageContents(categoryPageURI, logger);
            List<String> questionPageURIs = Utils.getMatchesFromPage(categoryPageContents, QUESTION_PAGE_FINDER_PATTERN, categoryPageURI + "/");

            if (questionPageURIs.size() <= 2) {
                logger.log("Didn't find enough question page URIs. URIs found: [" + String.join(",", questionPageURIs) + "]\n");
                throw new RuntimeException("Didn't find enough question page URIs: something has gone wrong\n");
            }

            for (String page : questionPageURIs) {
                checkQuestionPage(page, logger);
                Thread.sleep(resourceGetter.getThrottleWaitTimeMs());

            }
        } catch (InterruptedException e) {
            throw new RuntimeException("Interrupted, exiting");
        }
    }

    private void checkQuestionPage(@NonNull String page, @NonNull LambdaLogger logger) throws IOException {
        QuestionPage questionPage = new QuestionPage(getPageContents(page, logger));
        questionPage.validate(logger, resourceGetter, SQL_ENDPOINT);
    }

    private void checkStaticPages(@NonNull LambdaLogger logger) throws IOException {
        for (String page : STATIC_PAGES) {
            if (Thread.interrupted()) {
                logger.log("Interrupted, exiting\n");
                return;
            }
            getPageContents(BASE_PAGE_URI + "/" + page, logger);
        }
    }

    private @NonNull String getPageContents(@NonNull String uri, @NonNull LambdaLogger logger) throws IOException {
        logger.log("Getting page content: " + uri + "\n");
        return resourceGetter.getResource(uri);
    }
}
