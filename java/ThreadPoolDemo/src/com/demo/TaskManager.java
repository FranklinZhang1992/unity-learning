package com.demo;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import com.demo.tasks.ITask;

public class TaskManager {

	private static final int maxThreadCount = 2;
	private List<ITask> tasks = new ArrayList<ITask>();
	private ExecutorService threadPool;

	public void register(ITask task) {
		tasks.add(task);
	}

	public void startAll() {
		threadPool = Executors.newFixedThreadPool(maxThreadCount);
		for (ITask task : tasks) {
			start(task);
		}
		threadPool.shutdown();
	}

	private void start(ITask task) {
		TaskStarter ts = new TaskStarter(task);
		threadPool.execute(ts);
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
