package com.my.demo.timers;

import java.util.Date;
import java.util.Timer;

public class Main {

	public static void main(String[] args) {
		Timer timer = new Timer();
		timer.schedule(new MyTask(), new Date(), 2000);

		System.out.println("starts");
	}

}
