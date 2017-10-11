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
import com.demo.utils.Util;

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
    private Date timestamp;

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

    private void setMinuteField(final String minute, final Date currentDate) {
        minuteField = new CrontabMinuteField(minute, currentDate);
    }

    private void setHourField(final String hour, final Date currentDate) {
        hourField = new CrontabHourField(hour, currentDate);
    }

    private void setDayOfMonthField(final String dayOfMonth, final Date currentDate) {
        dayOfMonthField = new CrontabDayOfMonthField(dayOfMonth, currentDate);
    }

    private void setMonthField(final String month, final Date currentDate) {
        monthField = new CrontabMonthField(month, currentDate);
    }

    private void setDayOfWeekField(final String dayOfWeek) {
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
    private void setYearField(final String year) {
        yearField = new CrontabYearField(year);
    }

    public CrontabParser(final String cronString) {
        this(cronString, null);
    }

    public CrontabParser(final String cronString, final Date currentDate) {
        System.out.println("Initialize CrontabParser with trigger '" + cronString + "'");
        timestamp = currentDate == null ? new Date() : currentDate;
        String[] fields = cronString.split("\\s+");
        if (fields.length != 5 && fields.length != 6) {
            throw new InvalidCrontabError("Trigger is invalid.", I18NKeys.INVALID_TRIGGER);
        }

        try {
            // Property set must in sequence
            setMinuteField(fields[MINUTE_INDEX], timestamp);
            setHourField(fields[HOUR_INDEX], timestamp);
            setDayOfMonthField(fields[DAY_OF_MONTH_INDEX], timestamp);
            setMonthField(fields[MONTH_INDEX], timestamp);
            setDayOfWeekField(fields[DAY_OF_WEEK_INDEX]);
            // Set year field only when year field is received
            if (fields.length == 6) {
                setYearField(fields[YEAR_INDEX]);
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

        Calendar cal = Util.getCalendar(timestamp);
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
                cal.set(Calendar.MONTH, Util.convertCrontabMonthToCalendarMonth(allowedMonth));
                for (int allowedDayOfMonth : allowedDayOfMonths) {
                    cal.set(Calendar.DAY_OF_MONTH, allowedDayOfMonth);

                    int convertedYear = cal.get(Calendar.YEAR);
                    int convertedMonth = Util.convertCalendarMonthToCrontabMonth(cal.get(Calendar.MONTH));
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
        Calendar nextRunTime = Util.getCalendar(next(timestamp));
        System.out.println("isValidDateForOneTime: next run time is: " + nextRunTime.getTime());

        Calendar now = Util.getCalendar();
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
        return next(null);
    }

    /**
     * Calc crontab next run time from a specified time
     */
    public Date next(final Date currentDate) {
        if (dayOfWeekField.isSkipWeek()) {
            return getNextRunTimeWithJumpWeekLimit(currentDate);
        } else {
            return getNext(currentDate);
        }
    }

    /**
     * Calc next run time with the every-x-week limitation
     *
     * @return The next run time
     */
    private Date getNextRunTimeWithJumpWeekLimit(final Date currentDate) {
        Date nowDate = currentDate == null ? new Date() : currentDate;

        Date nextDate = getNext(nowDate);

        while (!Util.isIntegralMultipleWeeksLater(nowDate, nextDate, dayOfWeekField.getSkipWeekCount())
                && !isYearOutOfRange(nowDate, nextDate)) {
            nextDate = getNext(nextDate);
        }
        return nextDate;
    }

    /**
     * Get next run time from now or the given date
     *
     * @param startDate
     *            The date to start count
     * @return The next run time from now or the given date
     */
    private Date getNext(final Date startDate) {
        InternalTime t = new InternalTime(startDate);

        if (yearField != null) {
            if (nudgeYear(t, yearField.getYear())) {
                t.setMonth(0);
            }
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
     * To avoid infinite loop, we need a threshold (20 years) to avoid calc next
     * run time endlessly
     *
     * @param nowYear
     *            The current year number
     * @param nextYear
     *            The next year number
     * @return Whether the given nextYear is within 20 years from nowYear
     */
    private boolean isYearOutOfRange(final int nowYear, final int nextYear) {
        return nowYear + YEAR_THRESHOLD < nextYear;
    }

    /**
     * To avoid infinite loop, we need a threshold (20 years) to avoid calc next
     *
     * @param nowDate
     *            The current date
     * @param nextDate
     *            The next date
     * @return Whether the given nextDate is within 20 years from nowDate
     */
    private boolean isYearOutOfRange(final Date nowDate, final Date nextDate) {
        Calendar nowCal = Util.getCalendar(nowDate);
        Calendar nextCal = Util.getCalendar(nextDate);
        return isYearOutOfRange(nowCal.get(Calendar.YEAR), nextCal.get(Calendar.YEAR));
    }

    /**
     * @see interpolateDayOfWeeksWithoutCache
     *
     */
    private List<Integer> interpolateDayOfWeeks(final int year, final int month) {
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
    private List<Integer> interpolateDayOfWeeksWithoutCache(final int year, final int month) {
        Calendar cal = Util.getCalendar();
        // As java Calendar month field starts from 0, but Crontab month field
        // starts from 1, so we need to minus 1 here
        cal.set(Calendar.YEAR, year);
        cal.set(Calendar.MONTH, Util.convertCrontabMonthToCalendarMonth(month), 1);

        List<Integer> result = new ArrayList<Integer>();
        List<Integer> validDayOfMonths = dayOfMonthField.getFieldList();
        List<Integer> validDayOfWeeks = dayOfWeekField.getFieldList();

        while (Util.convertCalendarMonthToCrontabMonth(cal.get(Calendar.MONTH)) == month) {
            // In crontab day-of-week is in range 0-6, but in java Calendar,
            // day-of-week is in range of 1-7
            if (validDayOfMonths.contains(cal.get(Calendar.DAY_OF_MONTH)) && validDayOfWeeks
                    .contains(Util.convertCalendarDayOfWeekToCrontabDayOfWeek(cal.get(Calendar.DAY_OF_WEEK)))) {
                result.add(cal.get(Calendar.DAY_OF_MONTH));
            }
            cal.add(Calendar.DAY_OF_MONTH, 1);
        }

        return result;
    }

    /**
     * Nudge to a specified year (to specified year should later than the
     * current year) as the trigger required
     *
     * @param t
     *            The instance of InternalTime (global used time stamp)
     * @param toYear
     *            The year which will be nudged to
     * @return Whether the year is nudged
     */
    private boolean nudgeYear(final InternalTime t, final int toYear) {
        int originalYear = t.getYear();
        if (originalYear < toYear) {
            t.setYear(toYear);
            if (isYearOutOfRange(timestamp, t.toTime())) {
                throw new InvalidCrontabError("Trigger is invalid.", I18NKeys.INVALID_TRIGGER);
            }
            monthField.updateFieldList(t.toTime());
            return true;
        }
        return false;
    }

    /**
     * Nudge 1 year as the trigger required
     *
     * @param t
     *            The instance of InternalTime (global used time stamp)
     */
    private void nudgeYear(final InternalTime t) {
        nudgeYear(t, t.getYear() + 1);
    }

    /**
     * Nudge month as the trigger required
     *
     * @param t
     *            The instance of InternalTime (global used time stamp)
     */
    private void nudgeMonth(final InternalTime t) {
        List<Integer> allowedMonths = monthField.getFieldList();
        int nextValue = findBestNext(t.getMonth(), allowedMonths);

        if (nextValue == -1) {
            nudgeYear(t);
            t.setMonth(allowedMonths.get(0));
        } else {
            t.setMonth(nextValue);
        }
        dayOfMonthField.updateFieldList(t.toTime());
    }

    /**
     * Nudge date as the trigger required
     *
     * @param t
     *            The instance of InternalTime (global used time stamp)
     */
    private void nudgeDate(final InternalTime t) {
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
        hourField.updateFieldList(t.toTime());
    }

    /**
     * Nudge hour as the trigger required
     *
     * @param t
     *            The instance of InternalTime (global used time stamp)
     */
    private void nudgeHour(final InternalTime t) {
        List<Integer> allowedHours = hourField.getFieldList();
        int nextValue = findBestNext(t.getHour(), allowedHours);

        if (nextValue == -1) {
            nudgeDate(t);
            t.setHour(allowedHours.get(0));
        } else {
            t.setHour(nextValue);
        }
        minuteField.updateFieldList(t.toTime());
    }

    /**
     * Nudge minute as the trigger required
     *
     * @param t
     *            The instance of InternalTime (global used time stamp)
     */
    private void nudgeMinute(final InternalTime t) {
        List<Integer> allowedMinutes = minuteField.getFieldList();
        int nextValue = findBestNext(t.getMinute(), allowedMinutes);

        if (nextValue == -1) {
            nudgeHour(t);
            t.setMinute(allowedMinutes.get(0));
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
    private int findBestNext(final int current, final List<Integer> allowed) {
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
