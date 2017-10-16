package com.demo.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class Util {

    public static String getFormatedTime(final Date date) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        return sdf.format(date);
    }

    public static int convertCrontabMonthToCalendarMonth(final int crontabMonth) {
        return crontabMonth - 1;
    }

    public static int convertCalendarMonthToCrontabMonth(final int calendarMonth) {
        return calendarMonth + 1;
    }

    public static int convertCalendarDayOfWeekToCrontabDayOfWeek(final int calendarDayOfWeek) {
        return calendarDayOfWeek - 1;
    }

    public static int getMohthsBetween(final Date startDate, final Date endDate) {
        Calendar startCal = getCalendar(startDate);
        Calendar endCal = getCalendar(endDate);

        int month_interval = endCal.get(Calendar.MONTH) - startCal.get(Calendar.MONTH);
        int year_interval = endCal.get(Calendar.YEAR) - startCal.get(Calendar.YEAR);

        return year_interval * 12 + month_interval;
    }

    public static int getDaysBetween(final Date startDate, final Date endDate) {
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
    public static Date getFirstDayOfCurrentWeek(final Date currentDate) {
        Calendar cal = getCalendar(currentDate);

        int currentDayOfWeek = cal.get(Calendar.DAY_OF_WEEK);
        int different = 1 - currentDayOfWeek;
        cal.add(Calendar.DAY_OF_WEEK, different);
        return cal.getTime();
    }

    /**
     * Check if the interval days between nowDate and nextDate is integral multiple of weeks (The every-x-week trigger specified)
     *
     * @param nowDate
     *            The current date
     * @param nextDate
     *            The next date
     * @param The
     *            skip week count
     * @return Whether the interval days between nowDate and nextDate is integral multiple of weeks
     */
    public static boolean isIntegralMultipleWeeksLater(final Date nowDate, final Date nextDate, final int skipWeekCount) {
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
    public static boolean isIntegralMultipleOfGivenWeek(final int num, final int jumpWeekNum) {
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
    public static boolean isIntegralMultipleOfGivenNum(final int num, final int givenNum) {
        if (givenNum == 0) {
            return false;
        }
        return num % givenNum == 0;
    }

    public static boolean isSameYear(final Calendar srcCal, final Calendar destCal) {
        return srcCal.get(Calendar.YEAR) == destCal.get(Calendar.YEAR);
    }

    public static boolean isSameMonth(final Calendar srcCal, final Calendar destCal) {
        return srcCal.get(Calendar.YEAR) == destCal.get(Calendar.YEAR) && srcCal.get(Calendar.MONTH) == destCal.get(Calendar.MONTH);
    }

    public static boolean notReachTargetMonth(final Calendar srcCal, final Calendar destCal) {
        return srcCal.get(Calendar.YEAR) < destCal.get(Calendar.YEAR)
                || (srcCal.get(Calendar.YEAR) == destCal.get(Calendar.YEAR) && srcCal.get(Calendar.MONTH) < destCal.get(Calendar.MONTH));
    }

    public static boolean isSameDayOfMonth(final Calendar srcCal, final Calendar destCal) {
        return srcCal.get(Calendar.YEAR) == destCal.get(Calendar.YEAR) && srcCal.get(Calendar.MONTH) == destCal.get(Calendar.MONTH)
                && srcCal.get(Calendar.DAY_OF_MONTH) == destCal.get(Calendar.DAY_OF_MONTH);
    }

    public static boolean isSameHour(final Calendar srcCal, final Calendar destCal) {
        return srcCal.get(Calendar.YEAR) == destCal.get(Calendar.YEAR) && srcCal.get(Calendar.MONTH) == destCal.get(Calendar.MONTH)
                && srcCal.get(Calendar.DAY_OF_MONTH) == destCal.get(Calendar.DAY_OF_MONTH)
                && srcCal.get(Calendar.HOUR_OF_DAY) == destCal.get(Calendar.HOUR_OF_DAY);
    }

    /**
     * Check if the date represents by srcCal reached the date represents by destCal at the year level
     * 
     * @param srcCal
     *            The source date
     * @param destCal
     *            The destination date
     * @return Whether the date represents by srcCal reached the date represents by destCal at the year level
     */
    public static boolean hasReachedDestYear(final Calendar srcCal, final Calendar destCal) {
        return srcCal.after(destCal) || isSameYear(srcCal, destCal);
    }

    /**
     * Check if the date represents by srcCal reached the date represents by destCal at the month level
     * 
     * @param srcCal
     *            The source date
     * @param destCal
     *            The destination date
     * @return Whether the date represents by srcCal reached the date represents by destCal at the month level
     */
    public static boolean hasReachedDestMonth(final Calendar srcCal, final Calendar destCal) {
        return srcCal.after(destCal) || isSameMonth(srcCal, destCal);
    }

    /**
     * Check if the date represents by srcCal reached the date represents by destCal at the day-of-month level
     * 
     * @param srcCal
     *            The source date
     * @param destCal
     *            The destination date
     * @return Whether the date represents by srcCal reached the date represents by destCal at the day-of-month level
     */
    public static boolean hasReachedDestDayOfMonth(final Calendar srcCal, final Calendar destCal) {
        return srcCal.after(destCal) || isSameDayOfMonth(srcCal, destCal);
    }

    /**
     * Check if the date represents by srcCal reached the date represents by destCal at the hour level
     * 
     * @param srcCal
     *            The source date
     * @param destCal
     *            The destination date
     * @return Whether the date represents by srcCal reached the date represents by destCal at the hour level
     */
    public static boolean hasReachedDestHour(final Calendar srcCal, final Calendar destCal) {
        return srcCal.after(destCal) || isSameHour(srcCal, destCal);
    }

    public static Calendar getCalendar(final Date date) {
        Calendar cal = Calendar.getInstance();
        if (date != null) {
            cal.setTime(date);
        }
        return cal;
    }

    public static Calendar getCalendar() {
        return getCalendar(null);
    }

    /**
     * Convert a date from string to instance of Date
     *
     * @param dateStr
     *            The date string (e.g. 2017-10-01)
     * @return The instance of Date
     */
    public static Date getDateFromStr(final String dateStr) {
        if (dateStr != null) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                return sdf.parse(dateStr);
            } catch (ParseException e) {
                try {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    return sdf.parse(dateStr);
                } catch (ParseException e1) {
                    System.out.println("Failed to parse date string " + dateStr);
                }
            }
        }
        return null;
    }

    /**
     * Get the time which is one minute earlier than the original date
     * 
     * @param originalDate
     *            The original date
     * @return A new time which is one minute earlier than the original date
     */
    public static Date getOneMinuteEarlier(final Date originalDate) {
        Calendar cal = getCalendar(originalDate);
        cal.add(Calendar.MINUTE, -1);
        return cal.getTime();
    }

}
