package com.demo.worker.async;

public abstract class AsyncWorkerBase implements Runnable {

    @Override
    public void run() {
        try {
            handle();
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }

    protected abstract void handle();

}
