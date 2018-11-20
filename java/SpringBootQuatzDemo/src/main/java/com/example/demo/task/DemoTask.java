package com.example.demo.task;

import java.text.SimpleDateFormat;
import java.util.Date;

import org.springframework.beans.factory.annotation.Configurable;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@Configurable
@EnableScheduling
public class DemoTask {

    @Scheduled(cron = "*/7 * * * * *")
    public void cronTriggeredTask() {
        System.out.println("Executed at: " + getFormattedTime(new Date()));
    }

    private String getFormattedTime(Date date) {
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        return format.format(date);
    }
}
