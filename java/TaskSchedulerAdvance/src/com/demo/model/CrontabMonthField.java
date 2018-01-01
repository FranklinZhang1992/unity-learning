
package com.demo.model;

import java.util.Calendar;
import java.util.Date;
import java.util.List;

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

    public CrontabMonthField(final String fieldStr) {
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
        int currentMonth = Util.convertCalendarMonthToCrontabMonth(cal.get(Calendar.MONTH));
        return getMinValueOfGivenStep(currentMonth, cronStart);
    }

    public List<Integer> updateFieldList(Date currentDate) {
        if (isFieldListExpired(currentDate)) {
            setFieldStart(getUpdatedStart());
            clearFieldList();
            getFieldList().addAll(getSteppedRange(getFieldStart(), getFieldStop(), getFieldStep()));
        }
        return getFieldList();
    }

    protected boolean isFieldListExpired(Date currentDate) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(currentDate);
        return getTimestampField(Calendar.YEAR) == cal.get(Calendar.YEAR) ? false : true;
    }

    protected int getUpdatedStart() {
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.YEAR, getTimestampField(Calendar.YEAR));
        cal.set(Calendar.MONTH, Util.convertCrontabMonthToCalendarMonth(getLastValueInFieldList()));
        cal.add(Calendar.MONTH, getFieldStep());
        pushTimestamp(Calendar.YEAR);
        return Util.convertCalendarMonthToCrontabMonth(cal.get(Calendar.MONTH));
    }

}
