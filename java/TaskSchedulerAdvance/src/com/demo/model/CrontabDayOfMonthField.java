package com.demo.model;

import java.util.Date;

/**
 * Class for storing crontab trigger day field
 *
 */
public class CrontabDayOfMonthField extends AbstractCrontabField {

    /** Day in the month starts at 1 and ends at 31 (maximum) */
    public static final int MIN = 1;
    public static final int MAX = 31;
    public static final String FIELD_NAME = "day-of-month";

    public CrontabDayOfMonthField(final String fieldStr, final Date currentDate) {
        super(fieldStr, FIELD_NAME);
        validateField(fieldStr, currentDate);
    }

    @Override
    protected void validateField(final String fieldStr, final Date currentDate) {
        validateCommonField(fieldStr, MIN, MAX, currentDate);
    }

    /**
     * Check if the day-of-month field means every day of a month
     * 
     * @return Whether the day-of-month field means every day of a month
     */
    public boolean isEveryDayRange() {
        int totalLength = MAX - MIN + 1;
        return isFullRange(totalLength);
    }

}
