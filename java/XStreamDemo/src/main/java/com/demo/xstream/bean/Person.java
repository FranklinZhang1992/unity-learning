package com.demo.xstream.bean;

import com.thoughtworks.xstream.annotations.XStreamAsAttribute;

import java.util.List;

public class Person {
    @XStreamAsAttribute
    private String id;
    private String name;
    private String age;
    private Profile profile;
    private List<Address> addlist;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAge() {
        return age;
    }

    public void setAge(String age) {
        this.age = age;
    }

    public Profile getProfile() {
        return profile;
    }

    public void setProfile(Profile profile) {
        this.profile = profile;
    }

    public List<Address> getAddlist() {
        return addlist;
    }

    public void setAddlist(List<Address> addlist) {
        this.addlist = addlist;
    }
}
