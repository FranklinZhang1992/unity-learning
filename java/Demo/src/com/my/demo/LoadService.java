package com.my.demo;

import java.util.ArrayList;
import java.util.List;

public class LoadService {

    private final String POOL = "/developer/test_pool/";
    private boolean isReading = false;
    private List<Model> cache = null;

    private static LoadService instance;

    private LoadService() {

    }

    public void init() {
        if (instance == null) {
            instance = new LoadService();
        }
        if (cache == null) {
            cache = new ArrayList<Model>();
        }
    }

    public LoadService getInstance() {
        return instance;
    }

    private void loadFile(String uuid) {
        String fileName = POOL + uuid;

    }

    private boolean isReading() {
        return isReading;
    }

    private void startReading() {
        isReading = true;
    }

    public List<Model> list() {
        if (isReading()) {
            return cache;
        } else {
            return reLoad();
        }

    }

    private synchronized List<Model> reLoad() {
        startReading();
        
        return null;
    }
}
