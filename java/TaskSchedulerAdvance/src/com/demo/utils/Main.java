package com.demo.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class Main {

    protected static void testDaysBetween(Date startDate, Date endDate) {
        System.out.println("days between " + Util.getFormatedTime(startDate) + " and " + Util.getFormatedTime(endDate)
                + ": " + Util.getDaysBetween(startDate, endDate));
    }

    protected static void testIsIntegralMultipleWeeksLater(Date nowDate, Date nextDate) {
        System.out.println(Util.getFormatedTime(nowDate) + " and " + Util.getFormatedTime(nextDate) + ": "
                + Util.isIntegralMultipleWeeksLater(nowDate, nextDate, 2));
    }

    protected static void testAddMin(Date currentDate) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(currentDate);
        System.out.println(Util.getFormatedTime(cal.getTime()));
        cal.add(Calendar.MINUTE, 23);
        System.out.println(Util.getFormatedTime(cal.getTime()));
        cal.add(Calendar.MINUTE, 23);
        System.out.println(Util.getFormatedTime(cal.getTime()));
        cal.add(Calendar.MINUTE, 23);
        System.out.println(Util.getFormatedTime(cal.getTime()));
        cal.add(Calendar.MINUTE, 23);
        System.out.println(Util.getFormatedTime(cal.getTime()));
        cal.add(Calendar.MINUTE, 23);
        System.out.println(Util.getFormatedTime(cal.getTime()));
    }

    public static void main(String[] args) throws ParseException {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

        testDaysBetween(sdf.parse("2017-10-02 12:53:16"), sdf.parse("2017-10-09 12:53:16"));
        testDaysBetween(sdf.parse("2017-10-02 11:53:16"), sdf.parse("2017-10-09 12:53:16"));
        testDaysBetween(sdf.parse("2017-10-02 11:53:16"), sdf.parse("2017-10-09 10:53:16"));

    }

}
