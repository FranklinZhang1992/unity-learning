package com.demo.service;

import java.util.Date;
import java.util.concurrent.ArrayBlockingQueue;

import com.demo.model.CronModel;
import com.demo.store.StoreManager;

public class CronExecutor implements Runnable {

    private static final int CRON_QUEUE_SIZE = 20;
    private ArrayBlockingQueue<CronModel> queue = new ArrayBlockingQueue<CronModel>(CRON_QUEUE_SIZE);

    private Thread t;
    private String threadName;

    public CronExecutor(String name) {
        this.threadName = name;
        System.out.println("Creating " + this.threadName + " thread");
    }

    public void push(CronModel cronModel) {
        try {
            this.queue.put(cronModel);
            System.out.println("pushed " + cronModel.getId());
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void run() {
        System.out.println("Running " + this.threadName + " thiread");
        while (!this.queue.isEmpty()) {
            execute();
        }
        t = null;
    }

    public void start() {
        System.out.println("Starting " + threadName);
        if (t == null) {
            t = new Thread(this, this.threadName);
            t.start();
        } else {
            System.out.println("no need to create another thread");
        }
    }

    public boolean isInQueue(CronModel cronModl) {
        for (CronModel c : this.queue) {
            if (c.getId().equals(cronModl.getId())) {
                return true;
            }
        }
        return false;
    }

    private void execute() {
        System.out.println("executing");
        try {
            Thread.sleep(6000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        CronModel cron = this.queue.poll();
        System.out.println("deal with " + cron.getId());
        String command = cron.getCommand();
        System.out.println("command = " + command);
        StoreManager store = StoreManager.getInstance();
        cron.setLastRunTime(new Date());
        store.setNextRunTime(cron);
        store.update(cron);
        System.out.println("executed");
    }

}
