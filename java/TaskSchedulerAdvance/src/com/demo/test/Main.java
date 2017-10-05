package com.demo.test;

import java.util.Calendar;
import java.util.Date;
import java.util.List;

import com.demo.service.CrontabParser;
import com.demo.utils.Util;

public class Main {

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
        switch (option) {
        case 1: /** One time */
            trigger = "3 1 11 9 * 2037";
            break;
        case 2:/** One time */
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
            trigger = "3 1 1 */7 *";
            break;
        case 8: /** Monthly */
            trigger = "16 23 5 */7 *";
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

        System.out.println("Current time is: " + Util.getFormatedTime(new Date()));
        CrontabParser parser = new CrontabParser(trigger);

        int nextCount = 6;
        int i = 0;
        Date nextDate = null;
        while (i < nextCount) {
            i++;
            if (parser.isOneTimeCrontab()) {
                if (i > 1) {
                    continue;
                }
                if (!parser.isValidDateForOneTime()) {
                    System.out.println("[ERROR] Not a valie one time crontab");
                }
            }
            // printParser(parser);
            nextDate = getNext(parser, nextDate);
            System.out.println(Util.getFormatedTime(nextDate));
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

    public static void main(String[] args) {
        int caseNum = 12;
        for (int i = 1; i <= caseNum; i++) {
            test(i);
        }

    }

}
