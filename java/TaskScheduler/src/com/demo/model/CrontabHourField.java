package com.demo.model;

import java.util.List;

public class CrontabHourField extends AbstractCrontabField {

    public static final int MIN = 0;
    public static final int MAX = 23;

    public CrontabHourField(String fieldStr, List<Integer> fieldList) {
        super(fieldStr, fieldList);
    }

}
