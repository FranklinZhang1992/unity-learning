package com.demo.tasks;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.Timer;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.TimeUnit;

import com.demo.tasks.post.PostTask;
import com.demo.utils.LogUtil;

public class DispatchTask extends AbstractTaskBase {

    protected static final long DELAY = 3 * 1000L;
    private static final int jobCount = 5;
    private static final int THREAD_POOL_SIZE = 2;
    private ExecutorService threadPool;

    public DispatchTask(Timer taskTimer) {
        super(taskTimer);
        threadPool = Executors.newFixedThreadPool(THREAD_POOL_SIZE, new ThreadFactory() {
            int count = 1;

            @Override
            public Thread newThread(Runnable runnable) {
                return new Thread(runnable, "task-executor-" + count++);
            }

        });
    }

    @Override
    protected void execute() {
        LogUtil.log(getTaskName() + ": start dispatch");
        Random random = new Random();
        boolean failed = true;

        try {
            List<CompletableFuture<Void>> futures = new ArrayList<CompletableFuture<Void>>();
            for (int i = 0; i < jobCount; i++) {
                String taskName = "Post Task " + i;
                int duration = random.nextInt(5) + 2;
                PostTask task = new PostTask(taskName, duration);
                futures.add(CompletableFuture.runAsync(task, threadPool));
            }
            LogUtil.log(getTaskName() + ": job assigned");
            CompletableFuture<Void> all = CompletableFuture
                    .allOf(futures.toArray(new CompletableFuture[futures.size()]));
            all.get(3, TimeUnit.DAYS);
            LogUtil.log(getTaskName() + ": all jobs done");
            failed = false;
        } catch (Exception e) {
            LogUtil.log("error during execution: [" + e.getClass().getName() + "] " + e.getMessage());
        } finally {
            if (threadPool != null) {
                if (failed) {
                    LogUtil.log("force shutdown thread pool");
                    threadPool.shutdownNow();
                } else {
                    LogUtil.log("Gracefully shutdown thread pool");
                    threadPool.shutdown();
                }

                while (true) {
                    LogUtil.log("wait for running threads to stop");
                    try {
                        threadPool.awaitTermination(30, TimeUnit.SECONDS);
                    } catch (InterruptedException e) {
                        continue;
                    }
                    break;
                }
                threadPool = null;
            }
        }

    }

    public void shutdownThreadPool() {

    }

    @Override
    public long getDelay() {
        return DELAY;
    }

}
