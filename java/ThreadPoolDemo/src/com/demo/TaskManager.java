package com.demo;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import com.demo.tasks.ITask;
import com.demo.tasks.Logger;

public class TaskManager {

	private Logger logger = new Logger(TaskManager.class);
	private static final int maxThreadCount = 2;
	private List<ITask> tasks = new ArrayList<ITask>();
	private ExecutorService threadPool;

	public void register(ITask task) {
		tasks.add(task);
	}

	public void startAll() {
		threadPool = Executors.newFixedThreadPool(maxThreadCount);
		boolean failed = true;
		try {
			for (ITask task : tasks) {
				start(task);
			}
			failed = false;
		} finally {
			if (threadPool != null) {
				if (failed) {
					logger.info("task execution failed, forcibly shutdown thread pool");
					threadPool.shutdownNow();
				} else {
					logger.info("cleanly shut down shutdown thread pool");
					threadPool.shutdown();
				}
				while (true) {
					logger.info("waiting for thread pool to terminate");
					try {
						threadPool.awaitTermination(30, TimeUnit.MINUTES);
					} catch (InterruptedException e) {
						continue;
					}
					break;
				}
				logger.info("thread pool is terminated");
				threadPool = null;
			}
		}
	}

	private void start(ITask task) {
		TaskStarter ts = new TaskStarter(task);
		threadPool.execute(ts);
	}

	public void stopAll() {
		for (ITask task : tasks) {
			task.stop();
		}
	}

	private class TaskStarter implements Runnable {
		private ITask task;

		public TaskStarter(ITask task) {
			this.task = task;
		}

		@Override
		public void run() {
			task.start();
		}
	}
}
