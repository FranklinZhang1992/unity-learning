package com.demo.model;

import java.util.Date;

public class CronModel implements Cloneable {

    private String id;
    private String description;
    private String trigger;
    private String command;
    private Date nextRunTime;
    private Date lastRunTime;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getTrigger() {
        return trigger;
    }

    public void setTrigger(String trigger) {
        this.trigger = trigger;
    }

    public String getCommand() {
        return command;
    }

    public void setCommand(String command) {
        this.command = command;
    }

    public Date getNextRunTime() {
        return nextRunTime;
    }

    public void setNextRunTime(Date nextRunTime) {
        this.nextRunTime = nextRunTime;
    }

    public Date getLastRunTime() {
        return lastRunTime;
    }

    public void setLastRunTime(Date lastRunTime) {
        this.lastRunTime = lastRunTime;
    }

    @Override
    public Object clone() {
        CronModel cronModel = null;
        try {
            cronModel = (CronModel) super.clone();
        } catch (CloneNotSupportedException e) {
            e.printStackTrace();
        }
        return cronModel;
    }

    public void print() {
        System.out.print("Cron: id = " + this.id + ", description = " + this.description + ", trigger = " + this.trigger
                + ", command = " + this.command + ", last run time = " + this.lastRunTime + ", next run time = "
                + this.nextRunTime);
        System.out.println();
    }

}
