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

    protected static void inspect(int option) {
        String trigger = null;
        switch (option) {
        case 1: /** One time */
            break;
        case 2:/** One time */
            break;
        case 3:/** Daily */
            trigger = "3 13 * * 2/14";
            break;
        case 4: /** Daily */
            trigger = "3 14 */6 * *";
            break;
        case 5: /** Weekly */
            break;
        case 6: /** Weekly */
            trigger = "3 14 * * 2/14";
            break;
        case 7:/** Monthly */
            trigger = "3 13 1 */7 *";
            break;
        case 8: /** Monthly */
            trigger = "3 14 1 */7 *";
            break;
        default:
            throw new RuntimeException("Unknown option");
        }

        System.out.println("Current time is: " + Util.getFormatedTime(new Date()));
        CrontabParser parser = new CrontabParser(trigger);

        int nextCount = 10;
        int i = 0;
        Date nextDate = null;
        while (i < nextCount) {
            i++;
            // printParser(parser);
            nextDate = getNext(parser, nextDate);
            System.out.println(Util.getFormatedTime(nextDate));
        }
    }

    protected static Date getNext(CrontabParser parser, Date preNextDate) {
        if (preNextDate == null) {
            return parser.next();
        } else {
            Calendar cal = Calendar.getInstance();
            cal.setTime(preNextDate);
            // cal.add(Calendar.SECOND, 1);
            return parser.next(cal.getTime());
        }
    }

    public static void main(String[] args) {

        inspect(7);
    }

}
