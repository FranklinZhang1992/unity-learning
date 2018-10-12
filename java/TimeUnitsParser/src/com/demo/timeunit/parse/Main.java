package com.demo.timeunit.parse;

public class Main {

    public static void main(String[] args) {
        long duration = 1000 * 60 * 30;
        TimeUnitParser parser = new TimeUnitParser(duration);
        System.out.println(parser.getDurationBreakdown());
        System.out.println(parser.getMinutes() + " Minute(s)");
    }

}
