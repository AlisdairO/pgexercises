package com.pgexercises.sqlforwarder;

import com.pgexercises.exceptions.PGEInternalErrorException;
import com.pgexercises.exceptions.PGEUserException;
import org.junit.Test;

import java.sql.SQLException;

public class SQLForwarderTest {
  @Test
  public void testMultiQueryResponse() throws SQLException, PGEUserException, PGEInternalErrorException {
    /*SQLForwarder SQLForwarder = new SQLForwarder();
    APIGatewayProxyResponseEvent result = SQLForwarder.handleRequest(null, null);
    assertEquals(result.getStatusCode().intValue(), 200);
    assertEquals(result.getHeaders().get("Content-Type"), "application/json");
    String content = result.getBody();
    assertNotNull(content);
    assertTrue(content.contains("\"message\""));
    assertTrue(content.contains("\"hello world\""));
    assertTrue(content.contains("\"location\""));*/

    /*String sql = "blahblah";
    List<NativeQuery> queries = Parser.parseJdbcSql(sql, true, false, true, false);
    Assert.assertEquals(1, queries.size());
*/
  }
}
