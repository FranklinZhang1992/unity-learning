package com.demo.tasks;

import java.util.Timer;

import com.demo.utils.LogUtil;

public class MainTask extends AbstractTaskBase {

    protected static final long DELAY = 2 * 1000L;
    protected static final long duration = 2 * 1000L;
    protected static final int EXECUTION_COUNT = 3;

    public MainTask(Timer taskTimer) {
        super(taskTimer);
    }

    @Override
    protected void execute() {
        for (int i = 0; i < EXECUTION_COUNT; i++) {
            LogUtil.log(getTaskName() + " running");
            try {
                Thread.sleep(duration);
            } catch (InterruptedException e) {
            }
        }
    }

    @Override
    public long getDelay() {
        return DELAY;
    }

}
