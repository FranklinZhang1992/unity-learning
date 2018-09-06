package com.my.demo.multithread;

public class Main {

	public static void main(String[] args) {
//		Service.getInstance().test1();
//		Service.getInstance().test2();
		Runner t1 = new Runner();
//		Runner t2 = new Runner();
//		Runner t3 = new Runner();
//		Runner t4 = new Runner();
//		Runner t5 = new Runner();
//		Runner t6 = new Runner();
		
		
		t1.start();
//		t2.start();
//		t3.start();
//		t4.start();
//		t5.start();
//		t6.start();
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		t1.stop();
	}

}
