package com.pgexercises.monitor;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

public class TestUtils {
    public static String getResource(String resource) throws FileNotFoundException {
        ClassLoader classLoader = TestUtils.class.getClassLoader();
        File file = new File(classLoader.getResource(resource).getFile());
        return new Scanner(file).useDelimiter("\\Z").next();
    }
}
