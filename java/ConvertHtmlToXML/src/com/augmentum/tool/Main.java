package com.augmentum.tool;

import java.util.Map;

public class Main {
    public static void main(String[] args) {
        try {
            Map<String, String> commandMap = Commands.parseCommand(args);
            Convert convert = new Convert(commandMap.get("-input"), commandMap.get("-output"));
            convert.read();
            convert.convert();
            convert.write();
        } catch (Exception e) {
            System.err.println(e);
        }
    }
}
