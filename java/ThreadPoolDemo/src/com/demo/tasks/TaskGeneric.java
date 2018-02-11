package com.demo.tasks;

public class TaskGeneric extends TaskBase {

	private Logger logger = new Logger(TaskGeneric.class);
	private String name;
	private boolean cancel;

	public TaskGeneric(String name) {
		this.name = name;
	}

	@Override
	protected void startImpl() {
		logger.info(name + ": 10s task");
		long currentTime = System.currentTimeMillis();
		long expectedTime = currentTime + 10000;
		while (!isCancel() && expectedTime > System.currentTimeMillis()) {
			logger.info("cancel = " + cancel);
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
			}
		}
		logger.info(name + ": 10s task done");
	}

	@Override
	protected void stopImpl() {
		logger.info("call stopImpl");
		setCancel(true);
	}

	public synchronized boolean isCancel() {
		return cancel;
	}

	public synchronized void setCancel(boolean cancel) {
		this.cancel = cancel;
	}

}
