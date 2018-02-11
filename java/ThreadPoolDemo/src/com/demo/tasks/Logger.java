package com.demo.tasks;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

public class Logger {

	private String className;

	public Logger(Class<?> clazz) {
		this.className = clazz.getName();
	}

	private String getTimeStamp() {
		DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		Date now = new Date();
		return df.format(now);
	}

	public void info(String message) {
		info(message, null);
	}

	public void info(String message, Exception e) {
		log("INFO", message, e);
	}

	public void error(String message) {
		error(message, null);
	}

	public void error(String message, Exception e) {
		log("ERROR", message, e);
	}

	public void warn(String message) {
		warn(message, null);
	}

	public void warn(String message, Exception e) {
		log("WARN", message, e);
	}

	private void log(String level, String message, Exception e) {
		long threadId = Thread.currentThread().getId();
		String timeStamp = getTimeStamp();
		System.out.println(level + " " + timeStamp + " [" + className + "]." + threadId + " " + message);
		if (e != null) {
			System.out.println(e.toString());
		}
	}
}
