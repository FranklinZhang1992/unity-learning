package com.demo.worker.async;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;

public class Main {

    private static int jobCount = 3;

    protected static void testSync() {
        for (int i = 0; i < jobCount; i++) {
            DemoWorkder worker = new DemoWorkder();
            worker.handle();
        }
    }

    protected static void testAsync() {
        List<CompletableFuture<Void>> futures = new ArrayList<CompletableFuture<Void>>();
        for (int i = 0; i < jobCount; i++) {
            DemoWorkder worker = new DemoWorkder();
            futures.add(CompletableFuture.runAsync(worker));
        }
        System.out.println("job assigned");
        CompletableFuture<Void> all = CompletableFuture.allOf(futures.toArray(new CompletableFuture[futures.size()]));
        all.join();
    }

    protected static void showDuration(String title, long startTime, long endTime) {
        long duration = endTime - startTime;
        System.out.println("[" + title + "] Duration: " + duration / 1000 + "s");
    }

    public static void main(String[] args) {
        long startTime = System.currentTimeMillis();
        testSync();
        long endTime = System.currentTimeMillis();
        showDuration("Sync", startTime, endTime);

        startTime = System.currentTimeMillis();
        testAsync();
        endTime = System.currentTimeMillis();
        showDuration("Async", startTime, endTime);
    }

}
