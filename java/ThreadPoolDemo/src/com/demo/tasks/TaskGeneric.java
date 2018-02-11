package com.demo.tasks;

public class TaskGeneric extends TaskBase {

	private Logger logger = new Logger(TaskGeneric.class);
	private String name;

	public TaskGeneric(String name) {
		this.name = name;
	}

	@Override
	protected void startImpl() {
		logger.info(name + ": 5s task");
		long currentTime = System.currentTimeMillis();
		long expectedTime = currentTime + 5000;
		while (expectedTime > System.currentTimeMillis()) {
		}
		logger.info(name + ": 5s task done");
	}

	@Override
	protected void stopImpl() {
	}

}
