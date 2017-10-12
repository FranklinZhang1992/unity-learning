package com.demo.model;

import com.demo.exception.InvalidCrontabError;
import com.demo.i18n.I18NKeys;
import com.demo.utils.Util;

/**
 * Class for storing crontab trigger weekday field
 *
 */
public class CrontabDayOfWeekField extends AbstractCrontabField {
    /**
     * Day in a week starts at 0 and ends at 6 or starts at 1 and ends at 7 (0/7
     * represents Sunday)
     */
    public static final int MIN = 0;
    public static final int MAX = 7;
    public static final String FIELD_NAME = "day-of-week";
    private static final int WEEK_LENGTH = 7;

    private int skipWeekCont = 1;

    public CrontabDayOfWeekField(final String fieldStr) {
        super(fieldStr, FIELD_NAME);
        validateField(fieldStr);
        convertDayOfWeek();
    }

    /**
     * Check if this is a every-x-week task
     *
     * @return Whether this is a every-x-week task
     */
    public boolean isSkipWeek() {
        return skipWeekCont > 1;
    }

    /**
     * @return the dayOfWeekStep
     */
    public int getSkipWeekCount() {
        return skipWeekCont;
    }

    @Override
    protected void validateField(final String fieldStr) {
        StringBuilder processedFieldStr = new StringBuilder();

        String[] splitedField = fieldStr.split("/");
        int dayOfWeekStep = 0;
        // If the day-of-week field is x/y type
        if (splitedField.length == 2) {
            dayOfWeekStep = toInt(splitedField[1]);
            if (dayOfWeekStep >= WEEK_LENGTH) {
                if (!Util.isIntegralMultipleOfGivenNum(dayOfWeekStep, WEEK_LENGTH)) {
                    throw new InvalidCrontabError("Invalid crontab " + FIELD_NAME + " field '" + fieldStr + "'", I18NKeys.INVALID_FIELD, FIELD_NAME, fieldStr);
                }
                skipWeekCont = dayOfWeekStep / WEEK_LENGTH;
                dayOfWeekStep = 1;
            }
        }

        processedFieldStr.append(splitedField[0]);
        if (dayOfWeekStep > 1) {
            processedFieldStr.append("/");
            processedFieldStr.append(String.valueOf(dayOfWeekStep));
        }
        validateCommonField(processedFieldStr.toString(), MIN, MAX);
    }

    /**
     * Check if the day-of-week field means every day of a week
     *
     * @return Whether the day-of-week field means every day of a week
     */
    public boolean isEveryDayRange() {
        int totalLength = MAX - MIN + 1;
        return isFullRange(totalLength);
    }
}
