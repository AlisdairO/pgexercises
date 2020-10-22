package com.pgexercises.monitor.serialization;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.Assert;
import org.junit.Test;

import java.util.List;

public class ResultsTableTest {
    private static ObjectMapper MAPPER = new ObjectMapper();

    @Test
    public void serializationTest() throws JsonProcessingException {
        ResultsTable rt = new ResultsTable(List.of(
                List.of("row1value1", "row1value2"),
                List.of("row2value1", "row2value2"))
        );

        String rtSerialized = MAPPER.writeValueAsString(rt);
        Assert.assertTrue(rtSerialized.contains("row1value1"));
        ResultsTable qrDeserialized = MAPPER.readValue(rtSerialized, ResultsTable.class);
        Assert.assertEquals(rt, qrDeserialized);
    }
}
