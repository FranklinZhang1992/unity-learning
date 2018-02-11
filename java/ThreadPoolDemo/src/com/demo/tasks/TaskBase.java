package com.demo.tasks;

public abstract class TaskBase implements ITask {

	private Logger logger = new Logger(TaskBase.class);
	private boolean initialized;
	private boolean running;

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
		if (!running) {
			logger.info("starting");
			running = true;
			startImpl();
		}
	}

	@Override
	public void stop() {
		if (running) {
			logger.info("stopping");
			stopImpl();
			running = false;
		}
		logger.info("stopped");
	}

	protected void initImpl() {}

	abstract protected void startImpl();

	abstract protected void stopImpl();
}
