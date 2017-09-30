package com.demo.model;

import java.util.Arrays;
import java.util.Date;

/**
 * Class for storing crontab trigger year field
 *
 */
public class CrontabYearField extends AbstractCrontabField {

    public static final String FIELD_NAME = "year";

    public CrontabYearField(final String fieldStr, final Date currentDate) {
        super(fieldStr, FIELD_NAME);
        validateField(fieldStr, currentDate);
    }

    // As year field can only be a number, so we add a method to get it directly
    public int getYear() {
        if (getFieldList() == null) {
            return 0;
        } else {
            return getFieldList().get(0);
        }
    }

    @Override
    protected void validateField(final String fieldStr, final Date currentDate) {
        // The only limitation for year field is: it must be a number
        int yearNum = toInt(fieldStr);
        setFieldList(Arrays.asList(yearNum));
    }

}
