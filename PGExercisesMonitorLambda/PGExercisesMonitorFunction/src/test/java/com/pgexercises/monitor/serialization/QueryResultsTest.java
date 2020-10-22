package com.pgexercises.monitor.serialization;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.Assert;
import org.junit.Test;

import java.util.List;

public class QueryResultsTest {

    private static ObjectMapper MAPPER = new ObjectMapper();

    @Test
    public void serializationTest() throws JsonProcessingException {
        QueryResults qr = new QueryResults(
                List.of("header1", "header2"),
                new ResultsTable(List.of(
                        List.of("row1value1", "row1value2"),
                        List.of("row2value1", "row2value2")
                ))
        );

        String qrSerialized = MAPPER.writeValueAsString(qr);
        Assert.assertTrue(qrSerialized.contains("row1value1"));
        Assert.assertTrue(qrSerialized.contains("header1"));
        QueryResults qrDeserialized = MAPPER.readValue(qrSerialized, QueryResults.class);
        Assert.assertEquals(qr, qrDeserialized);
    }
}
