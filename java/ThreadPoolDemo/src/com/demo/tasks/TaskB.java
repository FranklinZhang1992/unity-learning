package com.demo.tasks;

public class TaskB extends TaskBase {

	private Logger logger = new Logger(TaskB.class);

	@Override
	protected void startImpl() {
		logger.info("taskB: 5s task");
		long currentTime = System.currentTimeMillis();
		long expectedTime = currentTime + 5000;
		while (expectedTime > System.currentTimeMillis()) {
		}
		logger.info("taskB: 5s task done");
	}

	@Override
	protected void stopImpl() {
	}

}
