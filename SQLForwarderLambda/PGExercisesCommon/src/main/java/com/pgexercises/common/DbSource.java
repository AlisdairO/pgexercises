package com.pgexercises.common;

import java.net.URI;

public class DbSource {
    private final URI uri;
    private final String database;
    private final String user;
    private final String password;

    public DbSource(URI uri, String database, String user, String password) {
        this.uri = uri;
        this.database = database;
        this.user = user;
        this.password = password;
    }

    public String getDatabase() {
        return database;
    }

    public URI getUri() {
        return uri;
    }

    public String getUser() {
        return user;
    }

    public String getPassword() {
        return password;
    }

    @Override
    public String toString() {
        return String.format("DbSource URI: %s, user: %s, password: <redacted>", uri, user);
    }

    public DbSource withDbOffset(int writeableDb) {
        return new DbSource(uri, database + writeableDb, user, password);
    }
}
