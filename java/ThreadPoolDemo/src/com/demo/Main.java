package com.demo;

import com.demo.tasks.TaskGeneric;

public class Main {

	public static void main(String[] args) {
		TaskManager tm = new TaskManager();
		tm.register(new TaskGeneric("TaskA"));
		tm.register(new TaskGeneric("TaskB"));
		tm.register(new TaskGeneric("TaskC"));
		tm.register(new TaskGeneric("TaskD"));
		tm.startAll();
	}

}
