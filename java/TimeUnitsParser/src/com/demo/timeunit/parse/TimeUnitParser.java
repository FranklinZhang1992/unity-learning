package com.demo.timeunit.parse;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class TimeUnitParser {

    private long durationMillis;

    public TimeUnitParser(long durationMillis) {
        if (durationMillis < 0) {
            throw new IllegalArgumentException(String.valueOf(durationMillis));
        }
        this.durationMillis = durationMillis;
    }

    public long getDays() {
        return TimeUnit.MILLISECONDS.toDays(durationMillis);
    }

    public long getHours() {
        return TimeUnit.MILLISECONDS.toHours(durationMillis);
    }

    public long getMinutes() {
        return TimeUnit.MILLISECONDS.toMinutes(durationMillis);
    }

    public long getSeconds() {
        return TimeUnit.MILLISECONDS.toSeconds(durationMillis);
    }

    public long getMilliseconds() {
        return durationMillis % 1000;

    }

    public String getDurationBreakdown() {
        long days = TimeUnit.MILLISECONDS.toDays(durationMillis);
        long hours = TimeUnit.MILLISECONDS.toHours(durationMillis) % 24;
        long minutes = TimeUnit.MILLISECONDS.toMinutes(durationMillis) % 60;
        long seconds = TimeUnit.MILLISECONDS.toSeconds(durationMillis) % 60;
        long milliseconds = durationMillis % 1000;

        List<String> outputList = new ArrayList<String>();
        if (days > 0) {
            outputList.add(String.format("%d Day(s)", days));
        }
        if (hours > 0) {
            outputList.add(String.format("%d Hour(s)", hours));
        }
        if (minutes > 0) {
            outputList.add(String.format("%d Minute(s)", minutes));
        }
        if (seconds > 0) {
            outputList.add(String.format("%d Second(s)", seconds));
        }
        if (milliseconds > 0) {
            outputList.add(String.format("%d Millisecond(s)", milliseconds));
        }
        return String.join(" ", outputList);
    }

    public String getDurationMinutes() {
        long days = getDays();
        long hours = getHours();
        long minutes = getMinutes();
        long seconds = getSeconds();
        long milliseconds = getMilliseconds();

        List<String> outputList = new ArrayList<String>();
        if (days > 0) {
            outputList.add(String.format("%d Day(s)", days));
        }
        if (hours > 0) {
            outputList.add(String.format("%d Hour(s)", hours));
        }
        if (minutes > 0) {
            outputList.add(String.format("%d Minute(s)", minutes));
        }
        if (seconds > 0) {
            outputList.add(String.format("%d Second(s)", seconds));
        }
        if (milliseconds > 0) {
            outputList.add(String.format("%d Millisecond(s)", milliseconds));
        }
        return String.join(" ", outputList);
    }

}
