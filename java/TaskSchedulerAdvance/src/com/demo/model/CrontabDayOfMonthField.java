package com.demo.model;

import java.util.Calendar;
import java.util.Date;

import com.demo.utils.Util;

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
        super(fieldStr, FIELD_NAME, currentDate);
        validateField(fieldStr);
    }

    @Override
    protected void validateField(final String fieldStr) {
        validateCommonField(fieldStr, MIN, MAX);
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

    @Override
    public int getFieldStart() {
        Calendar recordCal = Util.getCalendar(getTimestamp());
        int currentDayOfMonth = recordCal.get(Calendar.DAY_OF_MONTH);
        setFieldStart(getMinValueOfGivenStep(currentDayOfMonth, super.getFieldStart()));
        return super.getFieldStart();
    }

    /**
     * Update this field after month is nudged
     *
     * @param currentDate
     *            The current date, normally the month field is bigger than the month field in timestamp
     */
    public void updateFieldList(final Date currentDate) {
        if (needUpdate()) {
            super.updateFieldList(getFieldStartInTargetMonth(currentDate));
        }
    }

    /**
     * Get the start value in the new month
     *
     * @param currentDate
     *            The current date
     * @return The new start value
     */
    private int getFieldStartInTargetMonth(final Date currentDate) {
        Calendar currentCal = Util.getCalendar(currentDate);
        Calendar recordCal = Util.getCalendar(getTimestamp());

        while (!Util.hasReachedDestMonth(recordCal, currentCal)) {
            recordCal.add(Calendar.DAY_OF_MONTH, getFieldStep());

        }

        setTimestamp(recordCal.getTime());
        return recordCal.get(Calendar.DAY_OF_MONTH);
    }
}
