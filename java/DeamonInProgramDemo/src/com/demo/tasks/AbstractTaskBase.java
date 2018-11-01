package com.demo.tasks;

import java.util.Timer;
import java.util.TimerTask;

import com.demo.utils.LogUtil;

public abstract class AbstractTaskBase extends TimerTask {

    private Timer taskTimer;

    public AbstractTaskBase(Timer taskTimer) {
        this.taskTimer = taskTimer;
    }

    public String getTaskName() {
        String fullName = getClass().getName();
        return fullName.substring(fullName.lastIndexOf('.') + 1);
    }

    @Override
    public void run() {
        LogUtil.log("Start " + getTaskName());
        execute();
        LogUtil.log("Done " + getTaskName());
        taskTimer.cancel();
    }

    protected abstract void execute();

    public abstract long getDelay();

}
