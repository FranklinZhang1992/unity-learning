package com.demo.worker.async;

public class DemoWorkder extends AsyncWorkerBase {

    @Override
    protected void handle() {
        System.out.println("Start working");
        Work.get();
        System.out.println("Working Finished");
    }

}
