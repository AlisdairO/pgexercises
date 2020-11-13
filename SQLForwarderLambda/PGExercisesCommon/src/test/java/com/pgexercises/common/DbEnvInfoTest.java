package com.pgexercises.common;

import org.junit.Assert;
import org.junit.Test;

public class DbEnvInfoTest {
    private static final DbEnvInfo envInfo = new DbEnvInfo(
            "http://www.example.com",
            "uUser",
            "uPass",
            "aUser",
            "aPass",
            "us-east-2",
            "exercises",
            "pge-mgmt",
            1
    );

    @Test
    public void testReplacements() {
        String value = "<DBNAME> <REGION> <USER> <ADMINUSER> <ADMINDB> <WRITEABLE_DB_COUNT> <PASSWORD>";
        String resolved = envInfo.replaceEnvInfoInSql(value, 1);
        Assert.assertEquals(resolved, "exercises1 us-east-2 uUser aUser pge-mgmt 1 uPass");
    }

    @Test
    public void testUserReplacement() {
        String testSql = "DROP USER IF EXISTS <USER>;\n" +
                "CREATE USER <USER> with password '<PASSWORD>' VALID UNTIL 'infinity';\n" +
                "REVOKE ALL PRIVILEGES ON SCHEMA PUBLIC FROM <USER>;\n" +
                "ALTER USER <USER> SET statement_timeout = 750;";

        envInfo.replaceEnvInfoInSql(testSql);
    }
}
