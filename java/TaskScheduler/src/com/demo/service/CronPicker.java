package com.demo.service;

import java.util.Date;
import java.util.List;

import com.demo.model.CronModel;
import com.demo.store.StoreManager;

public class CronPicker implements Runnable {

    private Thread t;
    private String threadName;
    private CronExecutor executor;

    public CronPicker(String name) {
        this.threadName = name;
        this.executor = new CronExecutor("cronExecutor");
        System.out.println("Creating " + this.threadName + " thread");
    }

    @Override
    public void run() {
        System.out.println("Running " + this.threadName + " thiread");
        try {
            while (true) {
                System.out.println("scanning");
                pickExpiredCrons();
                Thread.sleep(5000);
            }
        } catch (InterruptedException e) {
            System.out.println("Thread " + this.threadName + " interrupted.");
        }
        System.out.println("Thread " + this.threadName + " exiting.");
    }

    public void start() {
        System.out.println("Starting " + threadName);
        if (t == null) {
            t = new Thread(this, this.threadName);
            t.start();
        }
    }

    private void pickExpiredCrons() {
        StoreManager storeManager = StoreManager.getInstance();
        List<CronModel> crons = storeManager.getAll();
        System.out.println("current crons:");
        storeManager.print();
        long currentTime = new Date().getTime();
        for (CronModel cron : crons) {
            if (cron.getNextRunTime().getTime() < currentTime && !this.executor.isInQueue(cron)) {
                this.executor.push(cron);
            }
        }
        this.executor.start();
    }

}
