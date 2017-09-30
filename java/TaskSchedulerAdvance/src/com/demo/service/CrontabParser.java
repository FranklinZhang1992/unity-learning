package com.demo.service;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.demo.exception.InvalidCrontabError;
import com.demo.i18n.I18NKeys;
import com.demo.model.AbstractCrontabField;
import com.demo.model.CrontabDayOfMonthField;
import com.demo.model.CrontabDayOfWeekField;
import com.demo.model.CrontabHourField;
import com.demo.model.CrontabMinuteField;
import com.demo.model.CrontabMonthField;
import com.demo.model.CrontabYearField;
import com.demo.model.InternalTime;

/**
 * Class for parsing crontab trigger string, aims to: 1. Validate whether the
 * crontab trigger is valid 2. Calc next run time
 *
 */
public class CrontabParser {

    private static final int MINUTE_INDEX = 0; // Regexp group index for minute
                                               // field
    private static final int HOUR_INDEX = 1; // Regexp group index for hour
                                             // field
    private static final int DAY_OF_MONTH_INDEX = 2; // Regexp group index for
                                                     // dayOfMonth field
    private static final int MONTH_INDEX = 3; // Regexp group index for month
                                              // field
    private static final int DAY_OF_WEEK_INDEX = 4; // Regexp group index for
                                                    // dayOfWeek field
    private static final int YEAR_INDEX = 5; // Regexp group index for year
                                             // field (optional)

    private static final int YEAR_THRESHOLD = 20; // 20 years threshold in this
                                                  // parser

    private CrontabMinuteField minuteField;
    private CrontabHourField hourField;
    private CrontabDayOfMonthField dayOfMonthField;
    private CrontabMonthField monthField;
    private CrontabDayOfWeekField dayOfWeekField;
    private CrontabYearField yearField;

    private Map<String, List<Integer>> interpolateDayOfWeekCache = new HashMap<String, List<Integer>>();

    public AbstractCrontabField getMinuteField() {
        return minuteField;
    }

    public AbstractCrontabField getHourField() {
        return hourField;
    }

    public AbstractCrontabField getDayOfMonthField() {
        return dayOfMonthField;
    }

    public AbstractCrontabField getMonthField() {
        return monthField;
    }

    public AbstractCrontabField getDayOfWeekField() {
        return dayOfWeekField;
    }

    public AbstractCrontabField getYearField() {
        return yearField;
    }

    private void setMinuteField(String minute) {
        minuteField = new CrontabMinuteField(minute);
    }

    private void setHourField(String hour) {
        hourField = new CrontabHourField(hour);
    }

    private void setDayOfMonthField(String dayOfMonth) {
        dayOfMonthField = new CrontabDayOfMonthField(dayOfMonth);
    }

    private void setMonthField(String month) {
        monthField = new CrontabMonthField(month);
    }

    private void setDayOfWeekField(String dayOfWeek) {
        dayOfWeekField = new CrontabDayOfWeekField(dayOfWeek);
    }

    /**
     * Check if this is a one time crontab by check whether year field is set
     *
     * @return Whether this is a one time crontab
     */
    public boolean isOneTimeCrontab() {
        return yearField != null;
    }

    /**
     * The year field can only be set when other fields are already set
     *
     * @param year
     */
    private void setYear(String year) {
        yearField = new CrontabYearField(year);
    }

    public CrontabParser(String cronString) {
        System.out.println("Initialize CrontabParser with trigger '" + cronString + "'");
        String[] fields = cronString.split("\\s+");
        if (fields.length != 5 && fields.length != 6) {
            throw new InvalidCrontabError("Trigger is invalid.", I18NKeys.INVALID_TRIGGER);
        }

        try {
            // Property set must in sequence
            setMinuteField(fields[MINUTE_INDEX]);
            setHourField(fields[HOUR_INDEX]);
            setDayOfMonthField(fields[DAY_OF_MONTH_INDEX]);
            setMonthField(fields[MONTH_INDEX]);
            setDayOfWeekField(fields[DAY_OF_WEEK_INDEX]);
            // Set year field only when year field is received
            if (fields.length == 6) {
                setYear(fields[YEAR_INDEX]);
            }
            validateCombinedFields();
        } catch (Exception e) {
            System.out.println("Failed to parse crontab trigger");
            throw new InvalidCrontabError("Trigger is invalid.", I18NKeys.INVALID_TRIGGER, e);
        }
    }

    /**
     * Validate if there are some conflict definitions between crontab fields
     *
     */
    private void validateCombinedFields() {
        validateDayOfMonthAndDayOfWeekFields();
        validateDayOfMonthAndMonthFields();
    }

    /**
     * Validate if there are some conflict definitions between crontab
     * day-of-month field and day-of-week field, e.g. day-of-month: 2,
     * day-of-week: 3/14
     *
     */
    private void validateDayOfMonthAndDayOfWeekFields() {
        if (!dayOfMonthField.isEveryDayRange() && dayOfWeekField.isSkipWeek()) {
            throw new InvalidCrontabError("Trigger is invalid.", I18NKeys.INVALID_TRIGGER);
        }
    }

    /**
     * Validate if there are some conflict definitions between day-of-month
     * field and month field
     *
     */
    private void validateDayOfMonthAndMonthFields() {
        boolean hasValidCombination = false;
        List<Integer> allowedMonths = monthField.getFieldList();
        List<Integer> allowedDayOfMonths = dayOfMonthField.getFieldList();
        List<Integer> allowedYears = new ArrayList<Integer>();

        Calendar cal = Calendar.getInstance();
        // Construct a list with all years which need to be traversed
        if (isOneTimeCrontab()) {
            allowedYears.add(yearField.getYear());
        } else {
            int currentYear = cal.get(Calendar.YEAR);
            for (int yearNum = currentYear; yearNum <= currentYear + YEAR_THRESHOLD; yearNum++) {
                allowedYears.add(yearNum);
            }
        }
        // Traverse year, month, and day to find if there is valid date
        // specified in trigger
        DONE: for (int allowedYear : allowedYears) {
            cal.set(Calendar.YEAR, allowedYear);
            for (int allowedMonth : allowedMonths) {
                cal.set(Calendar.MONTH, allowedMonth - 1);
                for (int allowedDayOfMonth : allowedDayOfMonths) {
                    cal.set(Calendar.DAY_OF_MONTH, allowedDayOfMonth);

                    int convertedYear = cal.get(Calendar.YEAR);
                    int convertedMonth = cal.get(Calendar.MONTH) + 1;
                    int convertedDayOfMonth = cal.get(Calendar.DAY_OF_MONTH);
                    if (convertedYear == allowedYear && convertedMonth == allowedMonth
                            && convertedDayOfMonth == allowedDayOfMonth) {
                        hasValidCombination = true;
                        break DONE;
                    }
                }
            }
        }

        // Check the hasValidCombination flag to know if there is valid date
        // specified in trigger
        if (!hasValidCombination) {
            throw new InvalidCrontabError("Trigger is invalid.", I18NKeys.INVALID_TRIGGER);
        }
    }

    /**
     * Check if a trigger is valid for one time task, this method is only for
     * the one-time trigger, if the one time trigger's next run time is older
     * than current time or it cannot be triggered in the specified year, this
     * means we can never reach the time the trigger specified, and the task
     * will never be executed
     *
     * @return Whether a trigger is reachable
     */
    public boolean isValidDateForOneTime() {
        boolean isValid = true;
        int yearNum = yearField.getYear();
        Calendar nextRunTime = Calendar.getInstance();
        nextRunTime.setTime(next());

        Calendar now = Calendar.getInstance();
        // If year field is set, then it means this is a one time cronjob, so
        // the time set must be later than current time
        if (now.compareTo(nextRunTime) > 0) {
            isValid = false;
        }
        // If year field is set, then it means this is a one time cronjob, so it
        // much be able to be triggered in the year user specified
        else if (now.compareTo(nextRunTime) < 0 && yearNum != nextRunTime.get(Calendar.YEAR)) {
            isValid = false;
        }
        return isValid;
    }

    /**
     * Calc crontab next run time
     */
    public Date next() {
        if (dayOfWeekField.isSkipWeek()) {
            return getNextRunTimeWithJumpWeekLimit();
        } else {
            return getNext();
        }
    }

    /**
     * Get the first day (Sunday) of current week
     *
     * @param currentDate
     *            Current date
     * @return The first day (Sunday) of current week
     */
    private Date getFirstDayOfCurrentWeek(Date currentDate) {
        Calendar cal = Calendar.getInstance();
        if (currentDate != null) {
            cal.setTime(currentDate);
        }

        int currentDayOfWeek = cal.get(Calendar.DAY_OF_WEEK);
        int different = 1 - currentDayOfWeek;
        cal.add(Calendar.DAY_OF_WEEK, different);
        return cal.getTime();
    }

    /**
     * Calc next run time with the every-x-week limitation
     *
     * @return The next run time
     */
    private Date getNextRunTimeWithJumpWeekLimit() {
        Date nowDate = new Date();

        Date nextDate = getNext();

        while (!isIntegralMultipleWeeksLater(getFirstDayOfCurrentWeek(nowDate), getFirstDayOfCurrentWeek(nextDate))
                && !isYearOutOfRange(nextDate)) {
            nextDate = getNext(nextDate);
        }
        return nextDate;
    }

    /**
     * Check if the interval days between nowDate and nextDate is integral
     * multiple of weeks (The every-x-week trigger specified)
     *
     * @param nowDate
     *            The current date
     * @param nextDate
     *            The next date
     * @return Whether the interval days between nowDate and nextDate is
     *         integral multiple of weeks
     */
    private boolean isIntegralMultipleWeeksLater(Date nowDate, Date nextDate) {
        int interval = getInterval(nowDate, nextDate);
        return isIntegralMultipleOfGivenWeek(interval, dayOfWeekField.getSkipWeekCount());
    }

    /**
     * @see getNext(Date startDate)
     */
    private Date getNext() {
        return getNext(null);
    }

    /**
     * Get next run time from now or the given date
     *
     * @param startDate
     *            The date to start count
     * @return The next run time from now or the given date
     */
    private Date getNext(Date startDate) {
        InternalTime t = new InternalTime(startDate);

        if (yearField != null) {
            t.setYear(yearField.getYear());
            t.setMonth(0);
        }

        if (!monthField.getFieldList().contains(t.getMonth())) {
            nudgeMonth(t);
            t.setDay(0);
        }

        if (!interpolateDayOfWeeks(t.getYear(), t.getMonth()).contains(t.getDay())) {
            nudgeDate(t);
            t.setHour(-1);
        }

        if (!hourField.getFieldList().contains(t.getHour())) {
            nudgeHour(t);
            t.setMinute(-1);
        }

        nudgeMinute(t);
        return t.toTime();
    }

    /**
     * Calc the interval days between startDate and endDate
     *
     * @param startDate
     *            The start date
     * @param endDate
     *            The end date
     * @return The interval days between startDate and endDate
     */
    public static int getInterval(Date startDate, Date endDate) {
        // Set start day and end day
        Calendar startCal = Calendar.getInstance();
        startCal.setTime(startDate);
        Calendar endCal = Calendar.getInstance();
        endCal.setTime(endDate);

        // Get day of year of start day and end day
        startCal.set(Calendar.HOUR_OF_DAY, 0);
        endCal.set(Calendar.HOUR_OF_DAY, 1);

        long startTime = startCal.getTimeInMillis();
        long endTime = endCal.getTimeInMillis();
        if (endTime < startTime) {
            return 0;
        } else {
            // Convert to number of days
            return (int) ((endTime - startTime) / (1000 * 3600 * 24));
        }
    }

    /**
     * To avoid infinite loop, we need a threshold (20 years) to avoid calc next
     * run time endlessly
     *
     * @param nextDate
     *            The date to be checked
     * @return Whether the given date is within 20 years from now
     */
    private boolean isYearOutOfRange(Date nextDate) {
        Date now = new Date();
        int intervalDay = getInterval(now, nextDate);
        // One year = 365 days
        return intervalDay > YEAR_THRESHOLD * 365;
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

    /**
     * @see interpolateDayOfWeeksWithoutCache
     *
     */
    private List<Integer> interpolateDayOfWeeks(int year, int month) {
        String key = String.valueOf(year) + "-" + String.valueOf(month);
        if (interpolateDayOfWeekCache.get(key) == null) {
            interpolateDayOfWeekCache.put(key, interpolateDayOfWeeksWithoutCache(year, month));
        }
        return interpolateDayOfWeekCache.get(key);
    }

    /**
     * Find a valid date list which satisfy two conditions: it's within user
     * specified dayOfMonth of month and it's within user specified dayOfMonth
     * of week An example: For a trigger * * 2 * 2, this method will return
     * dates satisfy two conditions: its 2th of a month and its Tuesday
     *
     * @param year
     *            The year
     * @param month
     *            The month
     * @return All valid days within the given year and month
     */
    private List<Integer> interpolateDayOfWeeksWithoutCache(int year, int month) {
        Calendar cal = Calendar.getInstance();
        // As java Calendar month field starts from 0, but Crontab month field
        // starts from 1, so we need to minus 1 here
        cal.set(year, month - 1, 1);

        List<Integer> result = new ArrayList<Integer>();
        List<Integer> validDayOfMonths = dayOfMonthField.getFieldList();
        List<Integer> validDayOfWeeks = dayOfWeekField.getFieldList();

        while (cal.get(Calendar.MONTH) == month - 1) {
            // In crontab day-of-week is in range 0-6, but in java Calendar,
            // day-of-week is in range of 1-7
            if (validDayOfMonths.contains(cal.get(Calendar.DAY_OF_MONTH))
                    && validDayOfWeeks.contains(cal.get(Calendar.DAY_OF_WEEK) - 1)) {
                result.add(cal.get(Calendar.DAY_OF_MONTH));
            }
            cal.add(Calendar.DAY_OF_MONTH, 1);
        }

        return result;
    }

    /**
     * Nudge year as the trigger required
     *
     * @param t
     *            The instance of InternalTime (global used time stamp)
     */
    private void nudgeYear(InternalTime t) {
        if (isYearOutOfRange(t.toTime())) {
            throw new InvalidCrontabError("Trigger is invalid.", I18NKeys.INVALID_TRIGGER);
        }
        t.setYear(t.getYear() + 1);
    }

    /**
     * Nudge month as the trigger required
     *
     * @param t
     *            The instance of InternalTime (global used time stamp)
     */
    private void nudgeMonth(InternalTime t) {
        List<Integer> allowedMonths = monthField.getFieldList();
        int nextValue = findBestNext(t.getMonth(), allowedMonths);

        if (nextValue == -1) {
            t.setMonth(allowedMonths.get(0));
            nudgeYear(t);
        } else {
            t.setMonth(nextValue);
        }
    }

    /**
     * Nudge date as the trigger required
     *
     * @param t
     *            The instance of InternalTime (global used time stamp)
     */
    private void nudgeDate(InternalTime t) {
        List<Integer> allowedDates = interpolateDayOfWeeks(t.getYear(), t.getMonth());
        while (allowedDates.isEmpty()) {
            nudgeMonth(t);
            t.setDay(0);
            allowedDates = interpolateDayOfWeeks(t.getYear(), t.getMonth());
        }
        int nextValue = findBestNext(t.getDay(), allowedDates);

        if (nextValue == -1) {
            nudgeMonth(t);
            t.setDay(0);
            nudgeDate(t);
        } else {
            t.setDay(nextValue);
        }
    }

    /**
     * Nudge hour as the trigger required
     *
     * @param t
     *            The instance of InternalTime (global used time stamp)
     */
    private void nudgeHour(InternalTime t) {
        List<Integer> allowedHours = hourField.getFieldList();
        int nextValue = findBestNext(t.getHour(), allowedHours);

        if (nextValue == -1) {
            t.setHour(allowedHours.get(0));
            nudgeDate(t);
        } else {
            t.setHour(nextValue);
        }
    }

    /**
     * Nudge minute as the trigger required
     *
     * @param t
     *            The instance of InternalTime (global used time stamp)
     */
    private void nudgeMinute(InternalTime t) {
        List<Integer> allowedMinutes = minuteField.getFieldList();
        int nextValue = findBestNext(t.getMinute(), allowedMinutes);

        if (nextValue == -1) {
            t.setMinute(allowedMinutes.get(0));
            nudgeHour(t);
        } else {
            t.setMinute(nextValue);
        }
    }

    /**
     * Find the min number in allowed array
     *
     * @param current
     * @param allowed
     * @return
     */
    private int findBestNext(int current, List<Integer> allowed) {
        int bestNext = -1;
        for (int val : allowed) {
            if (val > current) {
                bestNext = val;
                break;
            }
        }

        return bestNext;
    }

}
