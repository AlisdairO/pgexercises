package com.pgexercises.common;

import com.pgexercises.exceptions.PGEInternalErrorException;
import org.checkerframework.checker.nullness.qual.Nullable;
import software.amazon.awssdk.regions.Region;

import java.net.URI;
import java.util.regex.Matcher;

public class DbEnvInfo {
    private final URI jdbcURI;
    private final String unprivilegedUser;
    private final String unprivilegedUserPassword;
    private final String adminUser;
    private final String adminUserPassword;
    private final Region region;
    private final String baseDbName;
    private final String adminDbName;
    private final int writeableDbCount;

    public DbEnvInfo() throws PGEInternalErrorException {
        baseDbName = LambdaUtils.getRequiredEnvVar("baseDbName");
        adminDbName = LambdaUtils.getRequiredEnvVar("adminDbName");
        region = Region.of(LambdaUtils.getRequiredEnvVar("AWS_REGION"));
        jdbcURI = URI.create(LambdaUtils.getRequiredEnvVar("dbURI"));
        unprivilegedUser = LambdaUtils.getRequiredEnvVar("userAcct");
        unprivilegedUserPassword = SecretUtils.getPasswordForSecretId(LambdaUtils.getRequiredEnvVar("userPassSecretName"), region);
        adminUser = LambdaUtils.getRequiredEnvVar("adminAcct");
        adminUserPassword = SecretUtils.getPasswordForSecretId(LambdaUtils.getRequiredEnvVar("adminPassSecretName"), region);
        writeableDbCount = Integer.parseInt(LambdaUtils.getRequiredEnvVar("writeableDbCount"));
    }

    DbEnvInfo(String jdbcURI,
                     String unprivilegedUser,
                     String unprivilegedUserPassword,
                     String adminUser,
                     String adminUserPassword,
                     String region,
                     String baseDbName,
                     String adminDbName,
                     int writeableDbCount) {
        this.jdbcURI = URI.create(jdbcURI);
        this.unprivilegedUser = unprivilegedUser;
        this.unprivilegedUserPassword = unprivilegedUserPassword;
        this.adminUser = adminUser;
        this.adminDbName = adminDbName;
        this.adminUserPassword = adminUserPassword;
        this.region = Region.of(region);
        this.baseDbName = baseDbName;
        this.writeableDbCount = writeableDbCount;
    }

    public URI getJDBCURI() {
        return jdbcURI;
    }

    public Region getRegion() {
        return region;
    }

    public String getUnprivilegedUser() {
        return unprivilegedUser;
    }

    public String getUnprivilegedUserPassword() {
        return unprivilegedUserPassword;
    }

    public String getAdminUser() {
        return adminUser;
    }

    public String getAdminUserPassword() {
        return adminUserPassword;
    }

    public String getBaseDbName() {
        return baseDbName;
    }

    public String getAdminDbName() {
        return adminDbName;
    }

    public String replaceEnvInfoInSql(String sql) {
        return replaceEnvInfoInSql(sql, null);
    }

    public String replaceEnvInfoInSql(String sql, @Nullable Integer dbNameOffset) {
        return replaceEnvInfoInSql(sql, dbNameOffset, false);
    }

    public int getWriteableDbCount() {
        return writeableDbCount;
    }

    public String replaceEnvInfoInSql(String sql, @Nullable Integer dbNameOffset, boolean suppressLogging) {
        System.out.println("Replace env info start");
        if (!suppressLogging) {
            System.out.println("ENVINFO: " + this.toString());
            System.out.println("---- SQL-BEFORE BEGIN ----\n: " + sql + "---- SQL-BEFORE END ----\n");
        }
        // admin password intentionally left out, if we're ever pasting that
        // into SQL we're doing something wrong.
        String after =
                sql.replaceAll("<DBNAME>", Matcher.quoteReplacement(baseDbName + (dbNameOffset == null ? "" : dbNameOffset.toString())))
                .replaceAll("<REGION>", Matcher.quoteReplacement(region.toString()))
                .replaceAll("<USER>", Matcher.quoteReplacement(unprivilegedUser))
                .replaceAll("<ADMINUSER>", Matcher.quoteReplacement(adminUser))
                .replaceAll("<ADMINDB>", Matcher.quoteReplacement(adminDbName))
                .replaceAll("<WRITEABLE_DB_COUNT>", Integer.toString(writeableDbCount))
                .replaceAll("<PASSWORD>", Matcher.quoteReplacement(unprivilegedUserPassword));

        if (!suppressLogging) {
            System.out.println("\n---- SQL-AFTER BEGIN ----\n: " + after + "---- SQL-AFTER END ----\n");
        }
        System.out.println("Replace env info end");
        return after;
    }

    @Override
    public String toString() {
        return "jdbcURI: " + jdbcURI +
                "\n  unprivilegedUser: " + unprivilegedUser +
                "\n  unprivilegedUserPassword: <REDACTED>" +
                "\n  adminUser: " + adminUser +
                "\n  adminUserPassword <REDACTED>" +
                "\n  region: " + region +
                "\n  baseDbName: " + baseDbName +
                "\n  adminDbName: " + adminDbName +
                "\n  writeableDbCount: " + writeableDbCount;
    }
}
