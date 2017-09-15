package com.my.demo.time;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

public class Main {

	public static void main(String[] args) {
		long timeMillis = 1502148600114L;
		Date date = new Date(timeMillis);
		String timeZone = "America/New_York";
		SimpleDateFormat resultDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
		resultDateFormat.setTimeZone(TimeZone.getTimeZone(timeZone));
		String formatedDateStr = resultDateFormat.format(date);
		System.out.println(formatedDateStr);
	}

}
