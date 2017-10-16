package com.demo.model;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import com.demo.utils.Util;

/**
 * Class for recording time used in CrontabParser
 *
 */
public class InternalTime {

    private int year; // Range: must be positive integer
    private int month; // Range: 1-12
    private int day; // Range: 1-31
    private int hour; // Range: 0-23
    private int minute; // 0-59

    public int getYear() {
        return year;
    }

    public void setYear(final int year) {
        this.year = year;
    }

    public int getMonth() {
        return month;
    }

    public void setMonth(final int month) {
        this.month = month;
    }

    public int getDay() {
        return day;
    }

    public void setDay(final int day) {
        this.day = day;
    }

    public int getHour() {
        return hour;
    }

    public void setHour(final int hour) {
        this.hour = hour;
    }

    public int getMinute() {
        return minute;
    }

    public void setMinute(final int minute) {
        this.minute = minute;
    }

    private void initWithCalendar(final Calendar cal) {
        year = cal.get(Calendar.YEAR);
        // In java calendar, month range is 0-11, but in crontab, month range is
        // 1-12
        month = Util.convertCalendarMonthToCrontabMonth(cal.get(Calendar.MONTH));
        day = cal.get(Calendar.DAY_OF_MONTH);
        hour = cal.get(Calendar.HOUR_OF_DAY);
        minute = cal.get(Calendar.MINUTE);
    }

    public InternalTime() {
        this(null);
    }

    /**
     * @param startDate
     */
    public InternalTime(final Date startDate) {
        Calendar cal = Calendar.getInstance();
        if (startDate != null) {
            cal.setTime(startDate);
        }
        cal.clear(Calendar.SECOND);
        cal.clear(Calendar.MILLISECOND);
        initWithCalendar(cal);
    }

    public Date toTime() {
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.YEAR, year);
        // In java calendar, month range is 0-11, but in crontab, month range is
        // 1-12
        cal.set(Calendar.MONTH, Util.convertCrontabMonthToCalendarMonth(month));
        cal.set(Calendar.DAY_OF_MONTH, day);
        cal.set(Calendar.HOUR_OF_DAY, hour);
        cal.set(Calendar.MINUTE, minute);
        // Crontab does not care about seconds & millisecond field, so we always
        // set it as 0
        cal.clear(Calendar.SECOND);
        cal.clear(Calendar.MILLISECOND);

        return cal.getTime();
    }

    @Override
    public String toString() {
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        return df.format(toTime());
    }

    public String inspect() {
        StringBuilder sb = new StringBuilder();
        sb.append("year:");
        sb.append(year);
        sb.append(",month:");
        sb.append(month);
        sb.append(",day:");
        sb.append(day);
        sb.append(",hour:");
        sb.append(hour);
        sb.append(",minute:");
        sb.append(minute);
        return sb.toString();
    }

}
