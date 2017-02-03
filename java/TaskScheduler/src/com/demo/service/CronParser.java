package com.demo.service;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import com.demo.exception.InvalidCrontabError;
import com.demo.i18n.I18NKeys;
import com.demo.model.AbstractCrontabField;
import com.demo.model.CrontabDayField;
import com.demo.model.CrontabHourField;
import com.demo.model.CrontabMinuteField;
import com.demo.model.CrontabMonthField;
import com.demo.model.CrontabWeekdayField;
import com.demo.model.InternalTime;

public class CronParser {

    private static final int MINUTE_INDEX = 0;
    private static final int HOUR_INDEX = 1;
    private static final int DAY_INDEX = 2;
    private static final int MONTH_INDEX = 3;
    private static final int WEEKDAY_INDEX = 4;

    private static final int CRONTAB_FIELD_START_GROUP_NUM = 1;
    private static final int CRONTAB_FIELD_STOP_GROUP_NUM = 3;
    private static final int CRONTAB_FIELD_STEP_GROUP_NUM = 5;

    private static final String CRONTAB_FIELD_REGEXP = "^(\\d+)(-(\\d+)(/(\\d+))?)?$";

    private CrontabMinuteField minute;
    private CrontabHourField hour;
    private CrontabDayField day;
    private CrontabMonthField month;
    private CrontabWeekdayField weekday;
    private static Map<String, String> fieldClassMap = null;
    private Pattern crontabFildPattern = Pattern.compile(CRONTAB_FIELD_REGEXP);
    private Map<String, List<Integer>> interpolateWeekdaysCache = new HashMap<String, List<Integer>>();

    static {
        fieldClassMap = new HashMap<String, String>();
        fieldClassMap.put("minute", "com.demo.model.CrontabMinuteField");
        fieldClassMap.put("hour", "com.demo.model.CrontabHourField");
        fieldClassMap.put("day", "com.demo.model.CrontabDayField");
        fieldClassMap.put("month", "com.demo.model.CrontabMonthField");
        fieldClassMap.put("weekday", "com.demo.model.CrontabWeekdayField");

    }

    public AbstractCrontabField getMinute() {
        return minute;
    }

    public AbstractCrontabField getHour() {
        return hour;
    }

    public AbstractCrontabField getDay() {
        return day;
    }

    public AbstractCrontabField getMonth() {
        return month;
    }

    public AbstractCrontabField getWeekday() {
        return weekday;
    }

    private void setMinute(String minute) {
        this.minute = (CrontabMinuteField) setProperty("minute", minute);
    }

    private void setHour(String hour) {
        this.hour = (CrontabHourField) setProperty("hour", hour);
    }

    private void setDay(String day) {
        this.day = (CrontabDayField) setProperty("day", day);
    }

    private void setMonth(String month) {
        this.month = (CrontabMonthField) setProperty("month", month);
    }

    private void setWeekday(String weekday) {
        this.weekday = (CrontabWeekdayField) setProperty("weekday", weekday);
    }

    public CronParser(String cronString) {
        String[] fields = cronString.split("\\s+");
        if (fields.length != 5) {
            throw new InvalidCrontabError(cronString + " is not a valid trigger", I18NKeys.INVALID_TRIGGER, cronString);
        }

        this.setMinute(fields[MINUTE_INDEX]);
        this.setHour(fields[HOUR_INDEX]);
        this.setDay(fields[DAY_INDEX]);
        this.setMonth(fields[MONTH_INDEX]);
        this.setWeekday(fields[WEEKDAY_INDEX]);
    }

    private Object setProperty(String propertyName, String value) {
        try {
            Class<?> clazz = Class.forName(fieldClassMap.get(propertyName));
            Field minField = clazz.getField("MIN");
            Field maxField = clazz.getField("MAX");
            int min = minField.getInt(clazz);
            int max = maxField.getInt(clazz);

            String convertedValue = value.replaceAll("^\\*", min + "-" + max);
            List<Integer> fieldRawList = new ArrayList<Integer>();

            Arrays.asList(convertedValue.split(",")).forEach((subValue) -> {
                Matcher matcher = this.crontabFildPattern.matcher(subValue);
                if (matcher.matches()) {
                    String startStr = matcher.group(CRONTAB_FIELD_START_GROUP_NUM);
                    String stopStr = matcher.group(CRONTAB_FIELD_STOP_GROUP_NUM);
                    String stepStr = matcher.group(CRONTAB_FIELD_STEP_GROUP_NUM);
                    int start = Integer.valueOf(startStr);
                    int stop = stopStr == null ? start : Integer.valueOf(stopStr);
                    int step = stepStr == null ? 1 : Integer.valueOf(stepStr);

                    if (!rangeCheck(start, stop, step, min, max)) {
                        throw new InvalidCrontabError("invalid " + propertyName + " field => " + value,
                                I18NKeys.INVALID_FIELD, propertyName, value);
                    }
                    fieldRawList.addAll(getSteppedRange(start, stop, step));
                } else {
                    throw new InvalidCrontabError("invalid " + propertyName + " field => " + value,
                            I18NKeys.INVALID_FIELD, propertyName, value);
                }
            });

            List<Integer> fieldList = fieldRawList.stream().distinct().sorted().collect(Collectors.toList());
            Constructor<?> constructor = clazz.getConstructor(String.class, List.class);

            return constructor.newInstance(value, fieldList);

        } catch (InvalidCrontabError e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("Internal error");
        }
    }

    private boolean rangeCheck(int start, int stop, int step, int min, int max) {
        return isInRange(start, min, max) && isInRange(stop, min, max) && isInRange(step, min, max);
    }

    private boolean isInRange(int num, int min, int max) {
        return Math.max(min, num) == Math.min(num, max);
    }

    public List<Integer> getSteppedRange(int start, int stop, int step) {
        List<Integer> steppedRange = new ArrayList<>();
        if (start == stop && step == 1) {
            steppedRange.add(start);
            return steppedRange;
        }
        int len = stop - start;
        int num = len / step;
        for (int i = 0; i <= num; i++) {
            steppedRange.add(start + step * i);
        }
        return steppedRange;
    }

    public Date next() {
        InternalTime t = new InternalTime();

        if (!this.month.getFieldList().contains(t.getMonth())) {
            nudgeMonth(t);
            t.setDay(0);
        }

        if (!interpolateWeekdays(t.getYear(), t.getMonth()).contains(t.getDay())) {
            nudgeDate(t);
            t.setHour(-1);
        }

        if (!this.hour.getFieldList().contains(t.getHour())) {
            nudgeHour(t);
            t.setMinute(-1);
        }

        nudgeMinute(t);
        return t.toTime();
    }

    private List<Integer> interpolateWeekdays(int year, int month) {
        String key = String.valueOf(year) + "-" + String.valueOf(month);
        if (this.interpolateWeekdaysCache.get(key) == null) {
            this.interpolateWeekdaysCache.put(key, interpolateWeekdaysWithoutCache(year, month));
        }
        return this.interpolateWeekdaysCache.get(key);
    }

    private int convertDayOfWeek(int orig) {
        if (orig == 7) {
            return 0;
        } else {
            return orig;
        }
    }

    private List<Integer> interpolateWeekdaysWithoutCache(int year, int month) {
        Calendar cal = Calendar.getInstance();
        cal.set(year, month, 1);

        List<Integer> result = new ArrayList<Integer>();
        List<Integer> validDays = this.day.getFieldList();
        List<Integer> validWeekdays = this.weekday.getFieldList();

        while (cal.get(Calendar.MONTH) == month) {
            if (validDays.contains(cal.get(Calendar.DAY_OF_MONTH))
                    && validWeekdays.contains(convertDayOfWeek(cal.get(Calendar.DAY_OF_WEEK)))) {
                result.add(cal.get(Calendar.DAY_OF_MONTH));
            }
            cal.add(Calendar.DAY_OF_MONTH, 1);
        }

        return result;
    }

    private void nudgeYear(InternalTime t) {
        t.setYear(t.getYear() + 1);
    }

    private void nudgeMonth(InternalTime t) {
        List<Integer> allowedMonths = this.month.getFieldList();
        int nextValue = findBestNext(t.getMonth(), allowedMonths);

        if (nextValue == -1) {
            t.setMonth(allowedMonths.get(0));
            nudgeYear(t);
        } else {
            t.setMonth(nextValue);
        }
    }

    private void nudgeDate(InternalTime t) {
        List<Integer> allowedDates = interpolateWeekdays(t.getYear(), t.getMonth());
        while (allowedDates.isEmpty()) {
            nudgeMonth(t);
            t.setDay(0);
            allowedDates = interpolateWeekdays(t.getYear(), t.getMonth());
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

    private void nudgeHour(InternalTime t) {
        List<Integer> allowedHours = this.hour.getFieldList();
        int nextValue = findBestNext(t.getHour(), allowedHours);

        if (nextValue == -1) {
            t.setHour(allowedHours.get(0));
            nudgeDate(t);
        } else {
            t.setHour(nextValue);
        }
    }

    private void nudgeMinute(InternalTime t) {
        List<Integer> allowedMinutes = this.minute.getFieldList();
        int nextValue = findBestNext(t.getMinute(), allowedMinutes);

        if (nextValue == -1) {
            t.setMinute(allowedMinutes.get(0));
            nudgeHour(t);
        } else {
            t.setMinute(nextValue);
        }
    }

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

    public void inspect() {
        System.out.print("Minute(" + this.minute.getFieldStr() + "): ");
        this.minute.printFieldList();

        System.out.print("Hour(" + this.hour.getFieldStr() + "): ");
        this.hour.printFieldList();

        System.out.print("Day(" + this.day.getFieldStr() + "): ");
        this.day.printFieldList();

        System.out.print("Month(" + this.month.getFieldStr() + "): ");
        this.month.printFieldList();

        System.out.print("Weekday(" + this.weekday.getFieldStr() + "): ");
        this.weekday.printFieldList();
    }

}
