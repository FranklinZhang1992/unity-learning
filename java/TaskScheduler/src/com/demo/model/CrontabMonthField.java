
package com.demo.model;

/**
 * Class for storing crontab trigger month field
 *
 */
public class CrontabMonthField extends AbstractCrontabField {

    /** Month in a year starts at 1 and ends at 12 */
    private static final int MIN = 1;
    private static final int MAX = 12;
    public static final String FIELD_NAME = "month";

    public CrontabMonthField(final String fieldStr) {
        super(fieldStr, FIELD_NAME);
        validateField(fieldStr);
    }

    @Override
    protected void validateField(final String fieldStr) {
        validateCommonField(fieldStr, MIN, MAX);
    }

}
