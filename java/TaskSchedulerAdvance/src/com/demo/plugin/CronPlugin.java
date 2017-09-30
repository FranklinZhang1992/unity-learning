package com.demo.plugin;

import com.demo.service.CronPicker;

public class CronPlugin {

    public void start() {
        CronPicker picker = new CronPicker("cronPicker");
        picker.start();
    }

}
