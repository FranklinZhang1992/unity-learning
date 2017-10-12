package com.demo.test;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import com.demo.exception.PreConditionError;
import com.demo.service.CrontabParser;
import com.demo.utils.Util;

public class Main {
	protected static String getFormatedTime(Date date) {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		return sdf.format(date);
	}

	protected static Date getDateFromLong(long timeMillis) {
		return new Date(timeMillis);
	}

	protected static void printList(String title, List<Integer> list) {
		StringBuilder sb = new StringBuilder();
		for (Integer i : list) {
			sb.append(i);
			sb.append(",");
		}
		System.out.println(title);
		System.out.println("    " + sb.toString());
	}

	protected static void printParser(CrontabParser parser) {
		List<Integer> minuteList = parser.getMinuteField().getFieldList();
		printList("minute", minuteList);
		List<Integer> hourList = parser.getHourField().getFieldList();
		printList("hour", hourList);
		List<Integer> dayOfMonthList = parser.getDayOfMonthField().getFieldList();
		printList("day-of-month", dayOfMonthList);
		List<Integer> monthList = parser.getMonthField().getFieldList();
		printList("month", monthList);
		List<Integer> dayOfWeekList = parser.getDayOfWeekField().getFieldList();
		printList("day-of-week", dayOfWeekList);
	}

	protected static void test(int option) {
		System.out.println("Option is " + option);
		String trigger = null;
		String startDate = "2016-5-13 00:00:00";
		switch (option) {
		case 1: /** One time */
			startDate = null;
			trigger = "3 1 12 10 * 2018";
			break;
		case 2:/** One time */
			startDate = null;
			trigger = "* * * * * 2017";
			break;
		case 3:/** Daily */
			trigger = "3 1 */6 * *";
			break;
		case 4: /** Daily */
			trigger = "16 23 */6 * *";
			break;
		case 5: /** Weekly */
			trigger = "3 1 * * 4/14";
			break;
		case 6: /** Weekly */
			trigger = "16 23 * * 4/14";
			break;
		case 7:/** Monthly */
			trigger = "3 1 13 */7 *";
			break;
		case 8: /** Monthly */
			trigger = "16 23 13 */7 *";
			break;
		case 9: /** Hourly */
			trigger = "1 */9 * * *";
			break;
		case 10: /** Hourly */
			trigger = "59 */9 * * *";
			break;
		case 11: /** Minutely */
			trigger = "*/23 1 * * *";
			break;
		case 12: /** Minutely */
			trigger = "*/23 * * * *";
			break;
		case 13: /** stepped date */
			trigger = "16 15 1,5,6,10,22,24 * *";
			break;
		case 14: /** tricky date */
			trigger = "3 3 29 2 *";
			break;
		case 15: /** tricky case */
			trigger = "30 8 * 9-11 *";
			break;
		default:
			throw new RuntimeException("Unknown option");
		}

		System.out.println("Current time is: " + getFormatedTime(new Date()));
		System.out.println("trigger is: " + trigger);
		System.out.println("startDate is: " + startDate);
		Date nextDate = null;
		try {
			long next = getNearestNextRunTime(startDate, trigger);
			nextDate = getDateFromLong(next);
			// System.out.println(getFormatedTime(nextDate));
		} catch (PreConditionError e) {
			System.out.println("[ERROR] PreConditionError");
		}
		System.out.println("#######################################################################");
	}

	protected static Date getNext(CrontabParser parser, Date preNextDate) {
		if (preNextDate == null) {
			return parser.next();
		} else {
			Calendar cal = Calendar.getInstance();
			cal.setTime(preNextDate);
			return parser.next(cal.getTime());
		}
	}

	protected static long getNearestNextRunTime(String startDateStr, String trigger) {
		return getNearestNextRunTime(Util.getDateFromStr(startDateStr), trigger);
	}

	protected static long getNearestNextRunTime(Date startDate, String trigger) {
		CrontabParser parser = new CrontabParser(trigger, startDate);
		// printParser(parser);
		if (parser.isOneTimeCrontab() && !parser.isValidDateForOneTime()) {
			throw new PreConditionError("Not a valid one time trigger.");
		}
		return parser.next().getTime();
	}

	protected static void testGetDateFromStr() {
		String dateStr = "2017-02-13";

		Date date = null;
		if (dateStr != null) {
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

			try {
				date = sdf.parse(dateStr);
			} catch (ParseException e) {
				System.out.println("Failed to parse date string " + dateStr);
			}

		}
		System.out.println(getFormatedTime(date));

	}

	protected static void testMinuteInc() {
		String str = "2017-11-13 01:09:00";
		String destStr = "2017-11-15 01:10:00";
		Date date = Util.getDateFromStr(str);
		Date destDate = Util.getDateFromStr(destStr);
		Calendar cal = Util.getCalendar(date);
		while (destDate.getTime() > cal.getTimeInMillis()) {
			cal.add(Calendar.MINUTE, 23);
			System.out.println(getFormatedTime(cal.getTime()));
		}

	}

	protected static void validateStartDate(String startDateStr) {
		if (startDateStr != null) {
			Date startDate = Util.getDateFromStr(startDateStr);
			if (startDate == null) {
				throw new RuntimeException(startDateStr + " is not a valid start date.");
			}
			Calendar currentCal = Util.getCalendar();
			currentCal.clear(Calendar.MILLISECOND);
			currentCal.clear(Calendar.SECOND);
			currentCal.clear(Calendar.MINUTE);
			currentCal.set(Calendar.HOUR_OF_DAY, 0); // Deal with this field
														// separately as the
														// clear method does not
														// work for this field
														// (Reference to java
														// doc)
			if (startDate.getTime() < currentCal.getTimeInMillis()) {
				throw new RuntimeException("Cannot specify an expired start date " + startDateStr + ".");
			}

		}
	}

	protected static void testValidateStartDate() {
		String str = null;
		validateStartDate(str);
		System.out.println("OK");
	}

	protected static void testCalWeek() {
		Calendar cal = Calendar.getInstance();
		System.out.println(getFormatedTime(cal.getTime()) + " " + cal.get(Calendar.DAY_OF_WEEK));
		cal.add(Calendar.DAY_OF_MONTH, 1);
		System.out.println(getFormatedTime(cal.getTime()) + " " + cal.get(Calendar.DAY_OF_WEEK));
		cal.add(Calendar.DAY_OF_MONTH, 1);
		System.out.println(getFormatedTime(cal.getTime()) + " " + cal.get(Calendar.DAY_OF_WEEK));
		cal.add(Calendar.DAY_OF_MONTH, 1);
		System.out.println(getFormatedTime(cal.getTime()) + " " + cal.get(Calendar.DAY_OF_WEEK));
		cal.add(Calendar.DAY_OF_MONTH, 1);
		System.out.println(getFormatedTime(cal.getTime()) + " " + cal.get(Calendar.DAY_OF_WEEK));
		cal.add(Calendar.DAY_OF_MONTH, 1);
		System.out.println(getFormatedTime(cal.getTime()) + " " + cal.get(Calendar.DAY_OF_WEEK));
		cal.add(Calendar.DAY_OF_MONTH, 1);
		System.out.println(getFormatedTime(cal.getTime()) + " " + cal.get(Calendar.DAY_OF_WEEK));
	}

	protected static void testDayInc() {
		Calendar cal = Util.getCalendar(Util.getDateFromStr("2016-5-19 00:00:00"));
		Date destDate = Util.getDateFromStr("2017-10-30 01:03:00");
		System.out.println(getFormatedTime(cal.getTime()));
		while (cal.getTimeInMillis() < destDate.getTime()) {
			cal.add(Calendar.DAY_OF_MONTH, 14);
			System.out.println(getFormatedTime(cal.getTime()));
		}
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		int firstCaseNum = 5;
		int lastCaseNum = 5;
		for (int i = firstCaseNum; i <= lastCaseNum; i++) {
			test(i);
		}
		// testDayInc();
	}
}
