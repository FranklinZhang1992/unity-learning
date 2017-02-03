package com.demo.model;

import java.util.List;

public abstract class AbstractCrontabField {

    private String fieldStr;
    private List<Integer> fieldList;

    public AbstractCrontabField(String fieldStr, List<Integer> fieldList) {
        this.fieldStr = fieldStr;
        this.fieldList = fieldList;
    }

    public String getFieldStr() {
        return fieldStr;
    }

    public void setFieldStr(String fieldStr) {
        this.fieldStr = fieldStr;
    }

    public List<Integer> getFieldList() {
        return fieldList;
    }

    public void setFieldList(List<Integer> fieldList) {
        this.fieldList = fieldList;
    }

    public void printFieldList() {
        System.out.print(this.fieldList.get(0));
        for (int i = 1; i < this.fieldList.size(); i++) {
            System.out.print(" " + this.fieldList.get(i));
        }
        System.out.println();
    }

}
