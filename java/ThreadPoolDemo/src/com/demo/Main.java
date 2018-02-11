package com.demo;

import com.demo.tasks.TaskGeneric;

public class Main {

	public static void main(String[] args) {
		Main m = new Main();
		TaskManager tm = new TaskManager();
		tm.register(new TaskGeneric("TaskA"));
		tm.register(new TaskGeneric("TaskB"));
		tm.register(new TaskGeneric("TaskC"));
		tm.register(new TaskGeneric("TaskD"));
		Test test = m.new Test(tm);
		test.start();

		try {
			Thread.sleep(3000);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		 tm.stopAll();
	}

	class Test extends Thread {

		private TaskManager tm;

		public Test(TaskManager tm) {
			this.tm = tm;
		}

		@Override
		public void run() {
			tm.startAll();
		}

	}

}
