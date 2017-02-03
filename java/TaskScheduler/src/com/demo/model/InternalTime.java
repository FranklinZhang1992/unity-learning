package com.demo.model;

import java.util.Calendar;
import java.util.Date;

public class InternalTime {

    private int year;
    private int month;
    private int day;
    private int hour;
    private int minute;

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }

    public int getMonth() {
        return month;
    }

    public void setMonth(int month) {
        this.month = month;
    }

    public int getDay() {
        return day;
    }

    public void setDay(int day) {
        this.day = day;
    }

    public int getHour() {
        return hour;
    }

    public void setHour(int hour) {
        this.hour = hour;
    }

    public int getMinute() {
        return minute;
    }

    public void setMinute(int minute) {
        this.minute = minute;
    }

    public InternalTime() {
        Calendar cal = Calendar.getInstance();
        this.year = cal.get(Calendar.YEAR);
        this.month = cal.get(Calendar.MONTH) + 1;
        this.day = cal.get(Calendar.DAY_OF_MONTH);
        this.hour = cal.get(Calendar.AM_PM) == 0 ? cal.get(Calendar.HOUR) : cal.get(Calendar.HOUR) + 12;
        this.minute = cal.get(Calendar.MINUTE);
    }

    public Date toTime() {
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.YEAR, this.year);
        cal.set(Calendar.MONTH, this.month - 1);
        cal.set(Calendar.DAY_OF_MONTH, this.day);
        if (this.hour > 11) {
            cal.set(Calendar.HOUR, this.hour - 12);
            cal.set(Calendar.AM_PM, Calendar.PM);
        } else {
            cal.set(Calendar.HOUR, this.hour);
            cal.set(Calendar.AM_PM, Calendar.AM);
        }
        cal.set(Calendar.HOUR, this.hour > 11 ? this.hour - 12 : this.hour);
        cal.set(Calendar.MINUTE, this.minute);
        cal.set(Calendar.SECOND, 0);

        return cal.getTime();
    }

    public String toString() {
        return this.year + " " + this.month + " " + this.day + " " + this.hour + " " + this.minute;
    }

}
