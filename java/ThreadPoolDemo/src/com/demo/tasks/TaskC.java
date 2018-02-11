package com.demo.tasks;

public class TaskC extends TaskBase {

	private Logger logger = new Logger(TaskC.class);

	@Override
	protected void startImpl() {
		logger.info("TaskC: 5s task");
		long currentTime = System.currentTimeMillis();
		long expectedTime = currentTime + 5000;
		while (expectedTime > System.currentTimeMillis()) {
		}
		logger.info("TaskC: 5s task done");
	}

	@Override
	protected void stopImpl() {
	}

}
