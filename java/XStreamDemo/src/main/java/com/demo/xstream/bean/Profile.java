package com.demo.xstream.bean;

import com.thoughtworks.xstream.annotations.XStreamAsAttribute;

public class Profile {

    @XStreamAsAttribute
    private String type;
    private Job job;
    private String tel;
    private String remark;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Job getJob() {
        return job;
    }

    public void setJob(Job job) {
        this.job = job;
    }

    public String getTel() {
        return tel;
    }

    public void setTel(String tel) {
        this.tel = tel;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }
}
