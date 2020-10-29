package com.pgexercises.monitor;

import org.junit.Assert;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;

import java.net.URISyntaxException;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.regex.Pattern;

@SuppressWarnings("ConstantConditions")
public class UtilsTest {
    @Rule
    public ExpectedException expectedEx = ExpectedException.none();

    @Test
    public void testGoodBasicUri() throws URISyntaxException {
        Assert.assertEquals("https://pgexercises.com", Utils.buildUri("https://pgexercises.com", Map.of()).toString());
    }

    @Test (expected = URISyntaxException.class)
    public void testBadBasicUri() throws URISyntaxException {
        Utils.buildUri("https://pgexercises.com[][][]", Map.of());
    }

    @SuppressWarnings("argument.type.incompatible")
    @Test (expected = NullPointerException.class)
    public void testNullParamsUri() throws URISyntaxException {
        Utils.buildUri(null, null);
    }

    @Test
    public void testParamsUri() throws URISyntaxException {
        Assert.assertEquals("https://pgexercises.com?a=a", Utils.buildUri("https://pgexercises.com", new TreeMap(Map.of("a","a"))).toString());
    }

    @SuppressWarnings("argument.type.incompatible")
    @Test (expected = NullPointerException.class)
    public void testGetMatchesFromPageNullParams() throws Exception {
        Utils.getMatchesFromPage(null, null, null);
    }

    @Test
    public void testGetMatchesFromPage() throws Exception {
        List<String> matches = Utils.getMatchesFromPage("test\ntest1:'data',test1:'data2',\ntest2", Pattern.compile("test1:'([a-z0-9]*)'"), "p");
        Assert.assertEquals(List.of("pdata", "pdata2"), matches);
    }

    @SuppressWarnings("argument.type.incompatible")
    @Test (expected = NullPointerException.class)
    public void testGetSingleMatchFromPageNullParams() throws Exception {
        Utils.getSingleMatchFromPage(null, null);
    }

    @Test
    public void testGetSingleMatchFromPage() throws Exception {
        String match = Utils.getSingleMatchFromPage("test\ntest1:'data',\ntest2", Pattern.compile("test1:'([a-z0-9]*)'"));
        Assert.assertEquals("data", match);
    }

    @Test
    public void testGetSingleMatchFromPageTooMany() throws Exception {
        expectedEx.expectMessage("Expected match size of 1, got 2");
        String match = Utils.getSingleMatchFromPage("test\ntest1:'data',test1:'data2',\ntest2", Pattern.compile("test1:'([a-z0-9]*)'"));
        Assert.assertEquals("data", match);
    }

}
