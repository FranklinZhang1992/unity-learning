package com.demo.worker.async;

public class Work {

    public static void get() {
        try {
            Thread.sleep(3000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
