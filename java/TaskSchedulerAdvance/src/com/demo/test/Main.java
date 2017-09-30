package com.demo.test;

import com.demo.service.CrontabParser;
import com.demo.utils.Util;

public class Main {

	private static void test() {
		String trigger = "20 23 * */3 *";
		CrontabParser parser = new CrontabParser(trigger);
		System.out.println(Util.getFormatedTime(parser.next()));
	}

	public static void main(String[] args) {
		test();
	}

}
