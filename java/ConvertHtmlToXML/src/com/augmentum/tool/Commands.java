package com.augmentum.tool;

import java.util.HashMap;
import java.util.Map;

public class Commands {
    private static String[] keys = { "-input", "-output" };

    public static Map<String, String> parseCommand(String[] args) {
        Map<String, String> commadMap = new HashMap<String, String>();
        String currentKey = null;
        for (String arg : args) {
            if (isKey(arg)) {
                if (currentKey != null) {
                    throw new RuntimeException("value of " + currentKey + " is missing.");
                }
                currentKey = arg;
            } else {
                if (currentKey != null) {
                    commadMap.put(currentKey, arg);
                    currentKey = null;
                }
            }
        }
        if (currentKey != null) {
            throw new RuntimeException("value of " + currentKey + " is missing.");
        }
        return commadMap;
    }

    private static boolean isKey(String arg) {
        for (String key : keys) {
            if (key.equals(arg)) {
                return true;
            }
        }
        return false;
    }
}
