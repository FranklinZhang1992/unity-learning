package com.demo.test;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import com.demo.exception.PreConditionError;
import com.demo.service.CrontabParser;
import com.demo.utils.Util;

public class Main {

    protected static String getFormatedTime(Date date) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        return sdf.format(date);
    }

    protected static Date getDateFromLong(long timeMillis) {
        return new Date(timeMillis);
    }

    protected static void printList(String title, List<Integer> list) {
        StringBuilder sb = new StringBuilder();
        for (Integer i : list) {
            sb.append(i);
            sb.append(",");
        }
        System.out.println(title);
        System.out.println("    " + sb.toString());
    }

    protected static void printParser(CrontabParser parser) {
        List<Integer> minuteList = parser.getMinuteField().getFieldList();
        printList("minute", minuteList);
        List<Integer> hourList = parser.getHourField().getFieldList();
        printList("hour", hourList);
        List<Integer> dayOfMonthList = parser.getDayOfMonthField().getFieldList();
        printList("day-of-month", dayOfMonthList);
        List<Integer> monthList = parser.getMonthField().getFieldList();
        printList("month", monthList);
        List<Integer> dayOfWeekList = parser.getDayOfWeekField().getFieldList();
        printList("day-of-week", dayOfWeekList);
    }

    protected static void test(int option) {
        System.out.println("Option is " + option);
        String trigger = null;
        String startDate = "2017-11-13 00:00:00";
        switch (option) {
        case 1: /** One time */
            startDate = null;
            trigger = "3 1 12 10 * 2018";
            break;
        case 2:/** One time */
            startDate = null;
            trigger = "* * * * * 2017";
            break;
        case 3:/** Daily */
            trigger = "3 1 */6 * *";
            break;
        case 4: /** Daily */
            trigger = "16 23 */6 * *";
            break;
        case 5: /** Weekly */
            trigger = "3 1 * * 4/14";
            break;
        case 6: /** Weekly */
            trigger = "16 23 * * 4/14";
            break;
        case 7:/** Monthly */
            trigger = "3 1 13 */7 *";
            break;
        case 8: /** Monthly */
            trigger = "16 23 13 */7 *";
            break;
        case 9: /** Hourly */
            trigger = "1 */9 * * *";
            break;
        case 10: /** Hourly */
            trigger = "59 */9 * * *";
            break;
        case 11: /** Minutely */
            trigger = "*/23 1 * * *";
            break;
        case 12: /** Minutely */
            trigger = "*/23 * * * *";
            break;
        default:
            throw new RuntimeException("Unknown option");
        }

        System.out.println("Current time is: " + getFormatedTime(new Date()));
        System.out.println("trigger is: " + trigger);
        try {
            getNearestNextRunTime(startDate, trigger);
        } catch (PreConditionError e) {
            System.out.println("[ERROR] PreConditionError");
        }
        System.out.println("#######################################################################");
    }

    protected static Date getNext(CrontabParser parser, Date preNextDate) {
        if (preNextDate == null) {
            return parser.next();
        } else {
            Calendar cal = Calendar.getInstance();
            cal.setTime(preNextDate);
            return parser.next(cal.getTime());
        }
    }

    protected static long getNearestNextRunTime(String startDateStr, String trigger) {
        System.out.println("start time is: " + startDateStr);
        return getNearestNextRunTime(Util.getDateFromStr(startDateStr), trigger);
    }

    protected static long getNearestNextRunTime(Date startDate, String trigger) {
        long nearestNextRunTime = 0L;
        CrontabParser parser = new CrontabParser(trigger, startDate);
        // printParser(parser);
        if (parser.isOneTimeCrontab()) {
            if (!parser.isValidDateForOneTime()) {
                throw new PreConditionError("Not a valid one time trigger.");
            }
            Date nextRunDate = parser.next();
            System.out.println(getFormatedTime(nextRunDate));
            nearestNextRunTime = nextRunDate.getTime();
        } else {
            int loopCount = 1;
            int maxLoopCount = 6;
            Date nextRunDate = null;
            while (loopCount <= maxLoopCount) {
                loopCount++;
                nextRunDate = parser.next(nextRunDate);
                System.out.println(getFormatedTime(nextRunDate));
            }
            nearestNextRunTime = nextRunDate.getTime();
        }
        return nearestNextRunTime;
    }

    protected static void testGetDateFromStr() {
        String dateStr = "2017-02-13";

        Date date = null;
        if (dateStr != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            try {
                date = sdf.parse(dateStr);
            } catch (ParseException e) {
                System.out.println("Failed to parse date string " + dateStr);
            }
        }
        System.out.println(getFormatedTime(date));

    }

    /**
     * @param args
     */
    public static void main(String[] args) {
        int firstCaseNum = 1;
        int lastCaseNum = 8;
        for (int i = firstCaseNum; i <= lastCaseNum; i++) {
            test(i);
        }
    }

}
