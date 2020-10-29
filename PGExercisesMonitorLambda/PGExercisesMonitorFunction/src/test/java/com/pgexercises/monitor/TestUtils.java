package com.pgexercises.monitor;

import org.apache.commons.lang3.Validate;

import java.io.File;
import java.io.FileNotFoundException;
import java.net.URL;
import java.util.Scanner;

public class TestUtils {
    public static String getResource(String resource) throws FileNotFoundException {
        ClassLoader classLoader = Validate.notNull(TestUtils.class.getClassLoader());
        if (classLoader == null) {
            throw new RuntimeException("Couldn't get classloader");
        }
        URL u = classLoader.getResource(resource);
        if (u == null) {
            throw new FileNotFoundException("Couldn't find " + resource);
        }
        File file = new File(u.getFile());
        return new Scanner(file).useDelimiter("\\Z").next();
    }
}
