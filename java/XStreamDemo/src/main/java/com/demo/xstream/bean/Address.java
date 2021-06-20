package com.demo.xstream.bean;

import com.thoughtworks.xstream.annotations.XStreamAlias;

public class Address {

    @XStreamAlias("zipcode")
    private String zipCode;
    private String add;

    public String getZipCode() {
        return zipCode;
    }

    public void setZipCode(String zipCode) {
        this.zipCode = zipCode;
    }

    public String getAdd() {
        return add;
    }

    public void setAdd(String add) {
        this.add = add;
    }
}
