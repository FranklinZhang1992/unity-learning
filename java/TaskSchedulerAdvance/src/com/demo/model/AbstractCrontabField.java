package com.demo.model;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.demo.exception.InvalidCrontabError;

/**
 * Abstract class for storing crontab trigger fields
 *
 */
public abstract class AbstractCrontabField {

    /** Regexp for split fields from a trigger */
    protected static final String CRONTAB_FIELD_REGEXP = "^(\\d+)(-(\\d+)(/(\\d+))?)?$";
    protected Pattern crontabCommonFieldPattern = Pattern.compile(CRONTAB_FIELD_REGEXP);

    private static final int CRONTAB_FIELD_START_GROUP_NUM = 1; // Regexp group
                                                                // index for
                                                                // start time
    private static final int CRONTAB_FIELD_STOP_GROUP_NUM = 3; // Regexp group
                                                               // index for
                                                               // stop time
    private static final int CRONTAB_FIELD_STEP_GROUP_NUM = 5; // Regexp group
                                                               // index for
                                                               // step

    /** Original crontab trigger string */
    private String fieldRawStr;
    /**
     * The time range, e.g. If the month filed is '*', then this will be a 1-12
     * integer list
     */
    private List<Integer> fieldList;
    /** The name of the field */
    private String fieldName;

    /**
     * Constructor of AbstractCrontabField, set fieldRawStr and fieldName
     * property directly without any change
     *
     * @param fieldRawStr
     * @param fieldName
     */
    public AbstractCrontabField(final String fieldRawStr, final String fieldName) {
        this.fieldRawStr = fieldRawStr;
        this.fieldName = fieldName;
    }

    /**
     * Get the original field string
     *
     * @return The original field string
     */
    public String getFieldStr() {
        return fieldRawStr;
    }

    /**
     * Get a list which contains all valid numbers of a specified field, e.g. if
     * day-of-week field is 2-5, then this list will contain 2, 3, 4 and 5
     *
     * @return A list which contains all valid numbers of a specified field
     */
    public List<Integer> getFieldList() {
        return fieldList;
    }

    /**
     * Set fieldList directly
     *
     * @param fieldList
     *            A list which contains all valid numbers of a specified field
     */
    protected void setFieldList(final List<Integer> fieldList) {
        this.fieldList = fieldList;
    }

    /**
     * Get the size of the fieldList
     *
     * @return The size of the fieldList
     */
    protected int getFieldListSize() {
        if (fieldList == null) {
            return 0;
        }
        return fieldList.size();
    }

    /**
     * Check if the fieldList contains all numbers a field permit
     *
     * @param totalLength
     *            The total length of fieldList
     * @return Whether the fieldList contains all numbers a field permit
     */
    protected boolean isFullRange(final int totalLength) {
        if (fieldList != null && fieldList.size() == totalLength) {
            return true;
        }
        return false;
    };

    /**
     * Validate if the field is valid and fill in the fieldList
     *
     * @param fieldStr
     *            The field string
     */
    protected abstract void validateField(final String fieldStr);

    protected void validateCommonField(final String fieldStr, final int min, final int max) {
        // For uniform disposal, we convert all '*' to the range it represents
        String convertedValue = fieldStr.replaceAll("^\\*", min + "-" + max);
        // Stores the times includes in the trigger. e.g. If its a hour field,
        // and the trigger is *, then numbers 0-23 will all be stored into this
        // set, we
        // use set to avoid duplicate
        Set<Integer> fieldRawSet = new HashSet<Integer>();
        // A sorted list with unique elements which contains all time numbers a
        // trigger represents
        List<Integer> fieldList = new ArrayList<Integer>();

        // Below are logic to convert a trigger string into all time numbers it
        // represents.
        // e.g. If the hour part trigger is *, then we will get a orderly array
        // of 0-23
        List<String> fieldValues = Arrays.asList(convertedValue.split(","));
        for (String subValue : fieldValues) {
            Matcher matcher = crontabCommonFieldPattern.matcher(subValue);
            if (matcher.matches()) {
                String startStr = matcher.group(CRONTAB_FIELD_START_GROUP_NUM);
                String stopStr = matcher.group(CRONTAB_FIELD_STOP_GROUP_NUM);
                String stepStr = matcher.group(CRONTAB_FIELD_STEP_GROUP_NUM);
                // Treat all fields as x-y/z format
                // start = x
                int start = toInt(startStr);
                // stop = y, if y is not specified, then stop = start
                int stop = stopStr == null ? start : toInt(stopStr);
                // step = z, if z is not specified, then step = 1
                int step = stepStr == null ? 1 : toInt(stepStr);

                // The start, stop and step should all be in the max range
                if (!rangeCheck(start, stop, step, min, max)) {
                    throw new InvalidCrontabError(fieldName, fieldRawStr);
                }

                // Add all valid numbers of a field into the set
                fieldRawSet.addAll(getSteppedRange(start, stop, step));
            } else {
                throw new InvalidCrontabError(fieldName, fieldRawStr);
            }
        }

        fieldList.addAll(fieldRawSet);
        Collections.sort(fieldList);

        this.fieldList = fieldList;
    }

    /**
     * Check start, stop and step are in valid time range
     *
     * @param start
     *            Start time get from trigger
     * @param stop
     *            Stop time get from trigger
     * @param step
     *            Step get from trigger
     * @param min
     *            Min value of time range
     * @param max
     *            Max value of time range
     * @return Whether start, stop and step are in valid time range
     */
    private boolean rangeCheck(final int start, final int stop, final int step, final int min, final int max) {
        return isInRange(start, min, max) && isInRange(stop, min, max) && isStepInRange(step, start, stop);
    }

    /**
     * Check if (stop - start + 1) >= step && step >= 1
     *
     * @param step
     *            Step get from trigger
     * @param start
     *            Start time get from trigger
     * @param stop
     *            Stop time get from trigger
     * @return Whether (stop - start + 1) >= step && step >= 1
     */
    private boolean isStepInRange(final int step, final int start, final int stop) {
        int difference = stop - start + 1;
        return difference >= step && step >= 1;
    }

    /**
     * Util method to check if min <= num <= max
     *
     * @param num
     *            The number which will be validated
     * @param min
     *            The min value
     * @param max
     *            The max value
     * @return The result of the check
     */
    private boolean isInRange(final int num, final int min, final int max) {
        return Math.max(min, num) == Math.min(num, max);
    }

    /**
     * An example: If start is 1, stop is 3, step is 1, then a list of [1, 2, 3,
     * 4, 5] will be returned
     *
     * @param start
     *            Start time get from trigger
     * @param stop
     *            Stop time get from trigger
     * @param step
     *            Step get from trigger
     * @return A list of numbers
     */
    private List<Integer> getSteppedRange(final int start, final int stop, final int step) {
        List<Integer> steppedRange = new ArrayList<Integer>();
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

    /**
     * Parse a string to integer, throw CrontabValidationException when the
     * parsing failed
     *
     * @param str
     *            The string
     * @return The integer
     */
    protected int toInt(final String str) {
        try {
            return Integer.valueOf(str);
        } catch (Exception e) {
            throw new InvalidCrontabError(fieldName, fieldRawStr);
        }
    }

    /**
     * As 0 or 7 all represents Sunday, so we need to convert 7 to 0 to make it
     * easier to handle
     *
     */
    protected void convertDayOfWeek() {
        if (fieldList.contains(7)) {
            fieldList.remove(fieldList.indexOf(7));
            if (!fieldList.contains(0)) {
                fieldList.add(0);
                Collections.sort(fieldList);
            }
        }
    }
}
