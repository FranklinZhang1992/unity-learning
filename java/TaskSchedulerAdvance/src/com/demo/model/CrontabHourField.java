package com.demo.model;

import java.util.Date;

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
        super(fieldStr, FIELD_NAME);
        validateField(fieldStr, currentDate);
    }

    @Override
    protected void validateField(final String fieldStr, final Date currentDate) {
        validateCommonField(fieldStr, MIN, MAX, currentDate);
    }

}
