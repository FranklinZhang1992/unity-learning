package com.my.demo;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Date;

public class Main {
    public static void writeTest(final String guid, final String result, final String content, int index) {
        String dataFileName = "/developer/test_pool/" + guid;
        Date now = new Date();
        String message = "# Crontab execution history pool, created on " + now.toString() + "\n";

        File dataFile = new File(dataFileName);
        FileWriter fw = null;
        if (!dataFile.exists()) {
            try {
                fw = new FileWriter(dataFileName);
                fw.write(message);
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                try {
                    fw.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        try {
            fw = new FileWriter(dataFileName, true);
            String lineChar = "####################################\n";
            String writtenContent = index + ". result:" + result + "\n" + "content:" + content + "\n" + "timestamp:"
                    + new Date().getTime() + "\n" + lineChar;
            fw.write(writtenContent);
        } catch (IOException e1) {
            e1.printStackTrace();
        } finally {
            try {
                fw.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public static void readFileByLines(String fileName) {
        File file = new File(fileName);
        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new FileReader(file));
            String tempString = null;
            while ((tempString = reader.readLine()) != null) {
                System.out.println(tempString);
            }

        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException e1) {
                }
            }
        }
    }

    public static void writeTest() {
        String guid = "1122333";
        String result = "success";
        String content = "xxx 111 bbb" + new Date().toString();
        int count = 10000;
        long startTime = System.currentTimeMillis();
        for (int i = 0; i < count; i++) {
            writeTest(guid, result, content, i);
        }
        long endTime = System.currentTimeMillis();
        long inteval = (endTime - startTime) / 1000;
        System.out.println(inteval + "s");
    }

    private static void readTest() {
        String guid = "1122333";
        String dataFileName = "/developer/test_pool/" + guid;
        long startTime = System.currentTimeMillis();
        readFileByLines(dataFileName);
        long endTime = System.currentTimeMillis();
        long inteval = (endTime - startTime) / 1000;
        System.out.println(inteval + "s");
    }

    public static void main(String[] args) {
        // writeTest();

        readTest();

    }

}
