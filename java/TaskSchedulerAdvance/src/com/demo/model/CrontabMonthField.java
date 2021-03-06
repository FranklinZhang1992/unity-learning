
package com.demo.model;

import java.util.Calendar;
import java.util.Date;

import com.demo.utils.Util;

/**
 * Class for storing crontab trigger month field
 *
 */
public class CrontabMonthField extends AbstractCrontabField {

    /** Month in a year starts at 1 and ends at 12 */
    private static final int MIN = 1;
    private static final int MAX = 12;
    public static final String FIELD_NAME = "month";

    public CrontabMonthField(final String fieldStr, final Date currentDate) {
        super(fieldStr, FIELD_NAME, currentDate);
        validateField(fieldStr);
    }

    @Override
    protected void validateField(final String fieldStr) {
        validateCommonField(fieldStr, MIN, MAX);
    }

    @Override
    public int getFieldStart() {
        Calendar recordCal = Util.getCalendar(getTimestamp());
        int currentMonth = Util.convertCalendarMonthToCrontabMonth(recordCal.get(Calendar.MONTH));
        setFieldStart(getMinValueOfGivenStep(currentMonth, super.getFieldStart()));
        return super.getFieldStart();
    }

    /**
     * Update this field after year is nudged
     *
     * @param currentDate
     *            The current date, normally the year field is bigger than the year field in timestamp
     */
    public void updateFieldList(final Date currentDate) {
        if (needUpdate()) {
            super.updateFieldList(getFieldStartInTargetYear(currentDate));
        }
    }

    /**
     * Get the start value in the new year
     *
     * @param currentDate
     *            The current date
     * @return The new start value
     */
    private int getFieldStartInTargetYear(final Date currentDate) {
        Calendar currentCal = Util.getCalendar(currentDate);
        Calendar timestampCal = Util.getCalendar(getTimestamp());

        while (!Util.hasReachedDestYear(timestampCal, currentCal)) {
            timestampCal.add(Calendar.MONTH, getFieldStep());
        }

        setTimestamp(timestampCal.getTime());
        return Util.convertCalendarMonthToCrontabMonth(timestampCal.get(Calendar.MONTH));
    }
}
