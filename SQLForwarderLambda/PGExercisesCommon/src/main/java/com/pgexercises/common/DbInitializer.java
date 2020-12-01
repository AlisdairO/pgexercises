package com.pgexercises.common;

import com.pgexercises.exceptions.PGEInternalErrorException;
import org.checkerframework.checker.nullness.qual.Nullable;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.Scanner;

public class DbInitializer {
    private static final String recreateSchemaSQL;
    private static final String bookingsData;
    private static final String facilitiesData;
    private static final String membersData;
    private static final String finaliseRecreateSQL;
    private static final String createUnprivilegedUser;
    private static final String createDatabaseBefore;
    private static final String createDatabaseAfterRO;
    private static final String createDatabaseAfterRW;
    private static final String managementDbSQL;

    static {
        try {
            createDatabaseBefore = getResourceAsString("/sql/base-db-structure-before.sql");
            createDatabaseAfterRO = getResourceAsString("/sql/base-db-structure-after-ro.sql");
            createDatabaseAfterRW = getResourceAsString("/sql/base-db-structure-after-rw.sql");
            createUnprivilegedUser = getResourceAsString("/sql/base-create-unprivileged-user.sql");
            recreateSchemaSQL = getResourceAsString("/sql/clubdata-schemaonly.sql");
            bookingsData = getResourceAsString("/sql/clubdata-bookings.sql");
            facilitiesData = getResourceAsString("/sql/clubdata-facilities.sql");
            membersData = getResourceAsString("/sql/clubdata-members.sql");
            finaliseRecreateSQL = getResourceAsString("/sql/clubdata-finalise.sql");
            managementDbSQL = getResourceAsString("/sql/base-create-mgmt-db.sql");
        } catch (Exception e) {
            // stuff is impossibly broken if this goes wrong...
            throw new RuntimeException(e);
        }
    }

    // Doesn't do anything. This is to allow for loading the class to trigger static initialisation.
    public static void warmClass() {

    }

    private static void createUnprivilegedUser(CacheableConnection adminConnection, DbEnvInfo dbEnvInfo) throws SQLException, PGEInternalErrorException {
        adminConnection.executeUpdateInternal(dbEnvInfo.replaceEnvInfoInSql(createUnprivilegedUser, null));
    }

    public static void initFromScratch(CacheableConnection adminDbConnection, DbEnvInfo dbEnvInfo) throws SQLException, PGEInternalErrorException {
        createUnprivilegedUser(adminDbConnection, dbEnvInfo);
        createReadOnlyDb(adminDbConnection, dbEnvInfo);
        createWriteableDbs(adminDbConnection, dbEnvInfo);
        initManagementDb(adminDbConnection, dbEnvInfo);
    }

    private static void initManagementDb(CacheableConnection adminConnection, DbEnvInfo dbEnvInfo) throws PGEInternalErrorException {
        adminConnection.executeUpdateInternal(dbEnvInfo.replaceEnvInfoInSql(managementDbSQL, null));
    }

    private static void createWriteableDbs(CacheableConnection adminDbConnection, DbEnvInfo dbEnvInfo) throws PGEInternalErrorException {
        for (int i = 1; i <= dbEnvInfo.getWriteableDbCount(); i++) {
            adminDbConnection.executeUpdateInternal(dbEnvInfo.replaceEnvInfoInSql(createDatabaseBefore, i));
            CacheableConnection userDbConnection = new CacheableConnection(new DbSource(dbEnvInfo.getJDBCURI(),
                    dbEnvInfo.getBaseDbName() + i, dbEnvInfo.getAdminUser(), dbEnvInfo.getAdminUserPassword()
            ));
            try {
                resetDb(userDbConnection, dbEnvInfo, false, i, false);
            } finally {
                userDbConnection.closeConnection();
            }
        }
    }

    private static void createReadOnlyDb(CacheableConnection adminDbConnection, DbEnvInfo dbEnvInfo) throws PGEInternalErrorException {
        adminDbConnection.executeUpdateInternal(dbEnvInfo.replaceEnvInfoInSql(createDatabaseBefore, null));
        CacheableConnection userDbConnection = new CacheableConnection(new DbSource(dbEnvInfo.getJDBCURI(),
                dbEnvInfo.getBaseDbName(), dbEnvInfo.getAdminUser(), dbEnvInfo.getAdminUserPassword()
        ));
        try {
            resetDb(userDbConnection, dbEnvInfo, true, null, false);
        } finally {
            userDbConnection.closeConnection();
        }
    }

    public static void resetDb(CacheableConnection adminConnection, DbEnvInfo dbEnvInfo, boolean readOnly, @Nullable Integer dbNameOffset, boolean suppressLogging) throws PGEInternalErrorException {
        try {
            adminConnection.executeUpdateInternal(dbEnvInfo.replaceEnvInfoInSql(recreateSchemaSQL, dbNameOffset, suppressLogging));
            adminConnection.doCopyIn("COPY bookings (bookid, facid, memid, starttime, slots) FROM stdin", bookingsData);
            adminConnection.doCopyIn("COPY facilities (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance) FROM stdin;", facilitiesData);
            adminConnection.doCopyIn("COPY members (memid, surname, firstname, address, zipcode, telephone, recommendedby, joindate) FROM stdin;", membersData);
            adminConnection.executeUpdateInternal(dbEnvInfo.replaceEnvInfoInSql(finaliseRecreateSQL, dbNameOffset, suppressLogging));
            if (readOnly) {
                adminConnection.executeUpdateInternal(dbEnvInfo.replaceEnvInfoInSql(createDatabaseAfterRO, null, suppressLogging));
            } else {
                adminConnection.executeUpdateInternal(dbEnvInfo.replaceEnvInfoInSql(createDatabaseAfterRW, null, suppressLogging));
            }
        } catch (SQLException e) {
            throw new PGEInternalErrorException("Error resetting DB", e);
        }
    }


    private static String getResourceAsString(String resource) throws IOException, PGEInternalErrorException {
        try (InputStream is = DbInitializer.class.getResourceAsStream(resource)) {
            if (is == null) {
                throw new PGEInternalErrorException("Couldn't get resource");
            }
            try (Scanner stemp = new java.util.Scanner(is, StandardCharsets.UTF_8);
                 Scanner s = stemp.useDelimiter("\\A");) {
                return s.hasNext() ? s.next() : "";
            }
        }
    }
}
