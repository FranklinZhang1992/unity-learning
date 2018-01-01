package com.demo.utils;

import java.text.SimpleDateFormat;
import java.util.Date;

public class Util {

    public static String getFormatedTime(Date date) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        return sdf.format(date);
    }
    
    public static int convertCrontabMonthToCalendarMonth(int crontabMonth) {
        return crontabMonth - 1;
    }
    
    public static int convertCalendarMonthToCrontabMonth(int calendarMonth) {
        return calendarMonth + 1;
    }
    
    
}
