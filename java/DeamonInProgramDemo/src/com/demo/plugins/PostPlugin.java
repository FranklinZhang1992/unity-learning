package com.demo.plugins;

import java.util.Timer;

import com.demo.tasks.DispatchTask;

public class PostPlugin extends AbstractPluginBase {

    private Timer taskTimer;
    private DispatchTask task;

    @Override
    protected void startImpl() {
        taskTimer = new Timer("Post Task Timer");
        task = new DispatchTask(taskTimer);
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
