package com.my.demo.multithread;

public class Service {

	private static Service instance;

	private Service() {
		test1();

	}

	public synchronized static Service getInstance() {
		if (instance == null) {
			System.out.println("init");
			instance = new Service();
		}
		return instance;
	}

	public synchronized void test1() {
		System.out.println("test1");
	}

	public void test2() {
		System.out.println("test2");
	}
}
