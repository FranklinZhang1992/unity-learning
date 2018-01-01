package com.demo.test;

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

    protected static void inspect() {
        String trigger = "20 18 * */7 *";
        System.out.println("Current time is: " + Util.getFormatedTime(new Date()));
        CrontabParser parser = new CrontabParser(trigger);
        printParser(parser);
        Date nextDate = parser.next();

        System.out.println(Util.getFormatedTime(nextDate));

    }

    public static void main(String[] args) {

        inspect();
    }

}
