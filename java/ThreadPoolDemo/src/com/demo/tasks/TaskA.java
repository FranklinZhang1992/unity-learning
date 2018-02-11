package com.demo.tasks;

public class TaskA extends TaskBase {

	private Logger logger = new Logger(TaskA.class);

	@Override
	protected void startImpl() {
		logger.info("taskA: 5s task");
		long currentTime = System.currentTimeMillis();
		long expectedTime = currentTime + 5000;
		while (expectedTime > System.currentTimeMillis()) {
		}
		logger.info("taskA: 5s task done");
	}

	@Override
	protected void stopImpl() {
	}

}
