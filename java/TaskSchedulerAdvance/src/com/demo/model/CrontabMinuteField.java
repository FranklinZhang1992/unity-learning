package com.demo.model;

import java.util.Date;

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
        super(fieldStr, FIELD_NAME);
        validateField(fieldStr, currentDate);
    }

    @Override
    protected void validateField(final String fieldStr, final Date currentDate) {
        validateCommonField(fieldStr, MIN, MAX, currentDate);
    }

}
