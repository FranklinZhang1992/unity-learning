package com.demo.tasks.post;

import com.demo.utils.LogUtil;

public class PostTask implements Runnable {

    private static final long interval = 2 * 1000L;
    private String taskName;
    private int duration;

    /**
     * 
     * @param taskName
     * @param duration
     *            Execution duration (in second)
     */
    public PostTask(String taskName, int duration) {
        this.taskName = taskName;
        this.duration = duration;
    }

    @Override
    public void run() {
        LogUtil.log("start " + getTaskName());
        long startTime = System.currentTimeMillis();
        long currentTime = System.currentTimeMillis();
        long durationMillis = duration * 1000L;
        while (startTime + durationMillis >= currentTime) {
            LogUtil.log(getTaskName() + " executing");
            try {
                Thread.sleep(interval);
            } catch (InterruptedException e) {
            }
            currentTime = System.currentTimeMillis();
        }
        LogUtil.log("end " + getTaskName());

    }

    public String getTaskName() {
        return taskName;
    }

}
