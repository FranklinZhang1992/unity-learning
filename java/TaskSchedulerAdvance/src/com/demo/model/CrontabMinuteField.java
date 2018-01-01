package com.demo.model;

import java.util.Calendar;

/**
 * Class for storing crontab trigger minute field
 *
 */
public class CrontabMinuteField extends AbstractCrontabField {

    /** Minute in an hour starts at 0 and ends at 59 */
    private static final int MIN = 0;
    private static final int MAX = 59;
    public static final String FIELD_NAME = "minute";

    public CrontabMinuteField(final String fieldStr) {
        super(fieldStr, FIELD_NAME);
        validateField(fieldStr);
    }

    @Override
    protected void validateField(final String fieldStr) {
        validateCommonField(fieldStr, MIN, MAX);
    }

    @Override
    protected int getRealStart(int cronStart) {
        Calendar cal = Calendar.getInstance();
        int currentMinute = cal.get(Calendar.MINUTE);
        return getMinValueOfGivenStep(currentMinute, cronStart);
    }

}
