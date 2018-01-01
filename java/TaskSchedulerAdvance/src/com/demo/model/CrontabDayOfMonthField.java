package com.demo.model;

import java.util.Calendar;
import java.util.Date;
import java.util.List;

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

    public CrontabDayOfMonthField(final String fieldStr) {
        super(fieldStr, FIELD_NAME);
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
    protected int getRealStart(int cronStart) {
        Calendar cal = Calendar.getInstance();
        int currentDayOfMonth = cal.get(Calendar.DAY_OF_MONTH);
        return getMinValueOfGivenStep(currentDayOfMonth, cronStart);
    }

    public List<Integer> updateFieldList(Date currentDate) {
        if (isFieldListExpired(currentDate)) {
            setFieldStart(getUpdatedStart(currentDate));
            clearFieldList();
            getFieldList().addAll(getSteppedRange(getFieldStart(), getFieldStop(), getFieldStep()));
        }
        return getFieldList();
    }

    protected boolean isFieldListExpired(Date currentDate) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(currentDate);
        return getTimestampField(Calendar.MONTH) == cal.get(Calendar.MONTH)
                && getTimestampField(Calendar.YEAR) == cal.get(Calendar.YEAR) ? false : true;
    }

    protected int getUpdatedStart(Date currentDate) {
        System.out.println("currentDate is: " + Util.getFormatedTime(currentDate));
        Calendar currentCal = Calendar.getInstance();
        currentCal.setTime(currentDate);
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.MONDAY, Util.convertCrontabMonthToCalendarMonth(getTimestampField(Calendar.MONTH)));
        cal.set(Calendar.DAY_OF_MONTH, getLastValueInFieldList());
        while (cal.get(Calendar.MONTH) < currentCal.get(Calendar.MONTH)
                && cal.get(Calendar.YEAR) < currentCal.get(Calendar.YEAR)) {
            cal.add(Calendar.DAY_OF_MONTH, getFieldStep());
            if (cal.get(Calendar.MONTH) > getTimestampField(Calendar.MONTH)) {
                pushTimestamp(Calendar.MONTH);
            }
            System.out.println("timestamp is: " + Util.getFormatedTime(getTimestamp()));
        }

        return cal.get(Calendar.DAY_OF_MONTH);
    }

}
