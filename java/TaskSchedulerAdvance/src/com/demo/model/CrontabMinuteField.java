package com.demo.model;

import java.util.Calendar;
import java.util.Date;

import com.demo.utils.Util;

/**
 * Class for storing crontab trigger minute field
 *
 */
public class CrontabMinuteField extends AbstractCrontabField {

    /** Minute in an hour starts at 0 and ends at 59 */
    private static final int MIN = 0;
    private static final int MAX = 59;
    public static final String FIELD_NAME = "minute";

    public CrontabMinuteField(final String fieldStr, final Date currentDate) {
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
        int currentMinute = recordCal.get(Calendar.MINUTE);
        setFieldStart(getMinValueOfGivenStep(currentMinute, super.getFieldStart()));
        return super.getFieldStart();
    }

    /**
     * Update this field after hour is nudged
     *
     * @param currentDate
     *            The current date, normally the hour field is bigger than the hour field in timestamp
     */
    public void updateFieldList(final Date currentDate) {
        if (needUpdate()) {
            super.updateFieldList(getFieldStartInTargetHour(currentDate));
        }
    }

    /**
     * Get the start value in the new hour
     *
     * @param currentDate
     *            The current date
     * @return The new start value
     */
    private int getFieldStartInTargetHour(final Date currentDate) {
        Calendar currentCal = Util.getCalendar(currentDate);
        Calendar recordCal = Util.getCalendar(getTimestamp());

        while (!Util.hasReachedDestHour(currentCal, recordCal)) {
            recordCal.add(Calendar.MINUTE, getFieldStep());
        }

        setTimestamp(recordCal.getTime());
        return recordCal.get(Calendar.MINUTE);
    }
}
