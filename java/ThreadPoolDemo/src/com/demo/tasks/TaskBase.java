package com.demo.tasks;

public abstract class TaskBase implements ITask {

	private Logger logger = new Logger(TaskBase.class);
	private boolean initialized;

	@Override
	public void init() {
		if (!initialized) {
			logger.info("initializing");
			initImpl();
			initialized = true;
		}
		logger.info("initialized");
	}

	@Override
	public void start() {
		startImpl();
	}

	@Override
	public void stop() {
		stopImpl();
	}

	protected void initImpl() {
	}

	abstract protected void startImpl();

	abstract protected void stopImpl();
}
