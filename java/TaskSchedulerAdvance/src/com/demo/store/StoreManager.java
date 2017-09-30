package com.demo.store;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import com.demo.model.CronModel;
import com.demo.service.CrontabParser;

public class StoreManager {

    private static StoreManager instance = new StoreManager();

    private List<CronModel> crons = new ArrayList<CronModel>();
    private static final String CREATE_ACTION = "create";
    private static final String UPDATE_ACTION = "update";
    private static final String DELETE_ACTION = "delete";

    private StoreManager() {
    }

    public static StoreManager getInstance() {
        return instance;
    }

    private synchronized void apply(String action, CronModel cronModel) {
        switch (action) {
        case CREATE_ACTION:
            this.crons.add(cronModel);
            break;
        case UPDATE_ACTION:
            for (CronModel c : this.crons) {
                if (c.getId().equals(cronModel.getId())) {
                    c.setDescription(cronModel.getDescription());
                    c.setTrigger(cronModel.getTrigger());
                    c.setLastRunTime(cronModel.getLastRunTime());
                    c.setNextRunTime(cronModel.getNextRunTime());
                    c.setCommand(cronModel.getCommand());
                    break;
                }
            }
            break;
        case DELETE_ACTION:
            for (int i = 0; i < this.crons.size(); i++) {
                if (this.crons.get(i).getId().equals(cronModel.getId())) {
                    this.crons.remove(i);
                    break;
                }
            }
            break;
        }
    }

    public void setNextRunTime(CronModel cronModel) {
        String trigger = cronModel.getTrigger();
        if (trigger == null || "".equals(trigger)) {
            throw new RuntimeException("no trigger is found for " + cronModel.getId());
        }
        CrontabParser parser = new CrontabParser(trigger);
        Date next = parser.next();
        System.out.println("next run time is " + next);
        cronModel.setNextRunTime(next);
    }

    public CronModel create(CronModel cronModel) {
        String id = UUID.randomUUID().toString();
        cronModel.setId(id);
        setNextRunTime(cronModel);
        apply(CREATE_ACTION, cronModel);
        return cronModel;
    }

    public CronModel update(CronModel cronModel) {
        CronModel c = getById(cronModel.getId());
        if (c == null) {
            throw new RuntimeException("not found by id: " + cronModel.getId());
        }
        apply(UPDATE_ACTION, cronModel);
        return cronModel;
    }

    public void delete(String id) {
        CronModel cronModel = getById(id);
        if (cronModel == null) {
            throw new RuntimeException("not found by id: " + id);
        }
        apply(DELETE_ACTION, cronModel);

    }

    public CronModel getById(String id) {
        CronModel cronModel = null;
        for (CronModel c : this.crons) {
            if (c.getId().equals(id)) {
                cronModel = (CronModel) c.clone();
                break;
            }
        }
        return cronModel;
    }

    public List<CronModel> getAll() {
        List<CronModel> list = new ArrayList<CronModel>();
        for (CronModel c : this.crons) {
            CronModel cronModel = (CronModel) c.clone();
            list.add(cronModel);
        }
        return list;
    }

    public void print() {
        for (CronModel c : this.crons) {
            c.print();
        }
    }

}
