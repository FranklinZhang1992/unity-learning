package com.demo.model;

import java.util.Calendar;
import java.util.Date;

import com.demo.utils.Util;

/**
 * Class for storing crontab trigger hour field
 *
 */
public class CrontabHourField extends AbstractCrontabField {
    /** Hour in a day starts at 0 and ends at 23 */
    public static final int MIN = 0;
    public static final int MAX = 23;
    public static final String FIELD_NAME = "hour";

    public CrontabHourField(final String fieldStr, final Date currentDate) {
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
        int currentHour = recordCal.get(Calendar.HOUR_OF_DAY);
        setFieldStart(getMinValueOfGivenStep(currentHour, super.getFieldStart()));
        return super.getFieldStart();
    }

    /**
     * Update this field after day-of-month is nudged
     *
     * @param currentDate
     *            The current date, normally the day-of-month field is bigger
     *            than the day-of-month field in timestamp
     */
    public void updateFieldList(final Date currentDate) {
        if (needUpdate()) {
            super.updateFieldList(getFieldStartInTargetDayOfMonth(currentDate));
        }
    }

    /**
     * Get the start value in the new day-of-month
     *
     * @param currentDate
     *            The current date
     * @return The new start value
     */
    private int getFieldStartInTargetDayOfMonth(final Date currentDate) {
        Calendar currentCal = Util.getCalendar(currentDate);
        Calendar recordCal = Util.getCalendar(getTimestamp());

        while (!Util.isSameDayOfMonth(currentCal, recordCal)) {
            recordCal.add(Calendar.HOUR_OF_DAY, getFieldStep());
        }

        setTimestamp(recordCal.getTime());
        return recordCal.get(Calendar.HOUR_OF_DAY);
    }
}
