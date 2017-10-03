package com.demo.utils;

import java.text.SimpleDateFormat;
import java.util.Calendar;
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

    public static int convertCalendarDayOfWeekToCrontabDayOfWeek(int calendarDayOfWeek) {
        return calendarDayOfWeek - 1;
    }

    public static int getMohthsBetween(Date startDate, Date endDate) {
        Calendar startCal = getCalendar(startDate);
        Calendar endCal = getCalendar(endDate);

        int month_interval = endCal.get(Calendar.MONTH) - startCal.get(Calendar.MONTH);
        int year_interval = endCal.get(Calendar.YEAR) - startCal.get(Calendar.YEAR);

        return year_interval * 12 + month_interval;
    }

    public static int getDaysBetween(Date startDate, Date endDate) {
        Calendar startCal = getCalendar(startDate);
        Calendar endCal = getCalendar(endDate);

        startCal.set(Calendar.HOUR_OF_DAY, 0);
        startCal.set(Calendar.MINUTE, 0);
        startCal.set(Calendar.SECOND, 0);
        endCal.set(Calendar.HOUR_OF_DAY, 0);
        endCal.set(Calendar.MINUTE, 0);
        endCal.set(Calendar.SECOND, 0);

        return (int) ((endCal.getTime().getTime() / 1000 - startCal.getTime().getTime() / 1000) / 60 / 60 / 24);
    }

    /**
     * Get the first day (Sunday) of current week
     *
     * @param currentDate
     *            Current date
     * @return The first day (Sunday) of current week
     */
    public static Date getFirstDayOfCurrentWeek(Date currentDate) {
        Calendar cal = getCalendar(currentDate);

        int currentDayOfWeek = cal.get(Calendar.DAY_OF_WEEK);
        int different = 1 - currentDayOfWeek;
        cal.add(Calendar.DAY_OF_WEEK, different);
        return cal.getTime();
    }

    /**
     * Check if the interval days between nowDate and nextDate is integral
     * multiple of weeks (The every-x-week trigger specified)
     *
     * @param nowDate
     *            The current date
     * @param nextDate
     *            The next date
     * @param The
     *            skip week count
     * @return Whether the interval days between nowDate and nextDate is
     *         integral multiple of weeks
     */
    public static boolean isIntegralMultipleWeeksLater(Date nowDate, Date nextDate, int skipWeekCount) {
        int interval = getDaysBetween(getFirstDayOfCurrentWeek(nowDate), getFirstDayOfCurrentWeek(nextDate));
        return isIntegralMultipleOfGivenWeek(interval, skipWeekCount);
    }

    /**
     * Check if the number is integral multiple of the week (day * 7)
     *
     * @param num
     *            The number to be checked
     * @param jumpWeekNum
     *            The number of week
     * @return Whether the number is integral multiple of the week (day * 7)
     */
    public static boolean isIntegralMultipleOfGivenWeek(int num, int jumpWeekNum) {
        int daysInAWeek = 7;
        return isIntegralMultipleOfGivenNum(num, jumpWeekNum * daysInAWeek);
    }

    /**
     * Check if the number is integral multiple of the givenNum
     *
     * @param num
     *            The number to be checked
     * @param givenNum
     *            The given number
     * @return Whether the number is integral multiple of the givenNum
     */
    public static boolean isIntegralMultipleOfGivenNum(int num, int givenNum) {
        if (givenNum == 0) {
            return false;
        }
        return num % givenNum == 0;
    }

    public static boolean isSameYear(Calendar srcCal, Calendar destCal) {
        return srcCal.get(Calendar.YEAR) == destCal.get(Calendar.YEAR);
    }

    public static boolean isSameMonth(Calendar srcCal, Calendar destCal) {
        return srcCal.get(Calendar.YEAR) == destCal.get(Calendar.YEAR)
                && srcCal.get(Calendar.MONTH) == destCal.get(Calendar.MONTH);
    }

    public static boolean notReachTargetMonth(Calendar srcCal, Calendar destCal) {
        return srcCal.get(Calendar.YEAR) < destCal.get(Calendar.YEAR)
                || (srcCal.get(Calendar.YEAR) == destCal.get(Calendar.YEAR)
                        && srcCal.get(Calendar.MONTH) < destCal.get(Calendar.MONTH));
    }

    public static boolean isSameDayOfMonth(Calendar srcCal, Calendar destCal) {
        return srcCal.get(Calendar.YEAR) == destCal.get(Calendar.YEAR)
                && srcCal.get(Calendar.MONTH) == destCal.get(Calendar.MONTH)
                && srcCal.get(Calendar.DAY_OF_MONTH) == destCal.get(Calendar.DAY_OF_MONTH);
    }

    public static boolean isSameHour(Calendar srcCal, Calendar destCal) {
        return srcCal.get(Calendar.YEAR) == destCal.get(Calendar.YEAR)
                && srcCal.get(Calendar.MONTH) == destCal.get(Calendar.MONTH)
                && srcCal.get(Calendar.DAY_OF_MONTH) == destCal.get(Calendar.DAY_OF_MONTH)
                && srcCal.get(Calendar.HOUR_OF_DAY) == destCal.get(Calendar.HOUR_OF_DAY);
    }

    public static Calendar getCalendar(Date date) {
        Calendar cal = Calendar.getInstance();
        if (date != null) {
            cal.setTime(date);
        }
        return cal;
    }

    public static Calendar getCalendar() {
        return getCalendar(null);
    }
}
