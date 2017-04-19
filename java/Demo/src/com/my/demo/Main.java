package com.my.demo;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Main {

	public static void commonTest() {
		List<String> list = new ArrayList<String>();
		list.add(null);
		list.add(null);
		System.out.println(list.size());
	}

	public static void multiWriteTest() {
		writeTest("1");
		writeTest("2");
		writeTest("3");
	}

	public static void writeTest(String guid) {
		String result = "SUCCESS";
		String errorCode = "500";
		WriteService.init();
		int count = 2;
		long startTime = System.currentTimeMillis();
		for (int i = 0; i < count; i++) {
			String defaultMessage = "default" + i;
			WriteService.getInstance().write(guid, result, errorCode, defaultMessage, "a", "b", "c");
		}
		long endTime = System.currentTimeMillis();
		long interval = (endTime - startTime) / 1000;
		System.out.println(interval + "s");
	}

	public static void readTest() {
		readTest(null);
	}

	public static void readTest(String guid) {
		ReadService.init();
		Map<String, List<Message>> result = ReadService.getInstance().read(guid);
		for (String key : result.keySet()) {
			System.out.println("key: " + key);
			for (Message msg : result.get(key)) {
				System.out.println("  Time: " + msg.getTimestemp());
				System.out.println("    Result: " + msg.getResult());
				System.out.println("    ErrorCode: " + msg.getErrorCode());
				System.out.println("    DefaultMsg: " + msg.getDefaultMessage());
				System.out.println("    Args: " + msg.getArgs());
			}
		}
	}

	public static void main(String[] args) {
		// multiWriteTest();
		readTest();
		// commonTest();

	}

}
