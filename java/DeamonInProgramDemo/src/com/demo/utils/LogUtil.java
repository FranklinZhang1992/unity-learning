package com.demo.utils;

import java.text.SimpleDateFormat;
import java.util.Date;

public class LogUtil {

    private static String getFormattedTime() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        return sdf.format(new Date());
    }

    public static void log(String msg) {
        System.out.println("[" + getFormattedTime() + "] " + msg);
    }
}
