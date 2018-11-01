package com.demo.plugins;

import java.util.Timer;

import com.demo.tasks.MainTask;

public class MainPlugin extends AbstractPluginBase {

    private Timer taskTimer;
    private MainTask task;

    @Override
    protected void startImpl() {
        taskTimer = new Timer("Main Task Timer");
        task = new MainTask(taskTimer);
        taskTimer.schedule(task, task.getDelay());
    }

    @Override
    protected void stopImpl() {
        task.cancel();
        task = null;
        taskTimer.cancel();
        taskTimer = null;
    }

}
