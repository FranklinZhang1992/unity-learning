package com.demo.main;

import com.demo.model.CronModel;
import com.demo.plugin.CronPlugin;
import com.demo.store.StoreManager;

public class Main {

    private static void mockup() {
        StoreManager store = StoreManager.getInstance();
        CronModel cron1 = new CronModel();
        cron1.setDescription("test 1");
        cron1.setCommand("cmd1");
        cron1.setTrigger("* * * * *");
        store.create(cron1);

        CronModel cron2 = new CronModel();
        cron2.setDescription("test 2");
        cron2.setCommand("cmd2");
        cron2.setTrigger("* * * * *");
        store.create(cron2);

        CronModel cron3 = new CronModel();
        cron3.setDescription("test 3");
        cron3.setCommand("cmd3");
        cron3.setTrigger("* * * * *");
        store.create(cron3);

        System.out.println("=== Mockup ===");
        store.print();
        System.out.println("=== Mockup ===");
    }

    public static void main(String[] args) {

        mockup();

        CronPlugin cronPlugin = new CronPlugin();
        cronPlugin.start();
    }

}
