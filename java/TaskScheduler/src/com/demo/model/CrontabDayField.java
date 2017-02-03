package com.demo.model;

import java.util.List;

public class CrontabDayField extends AbstractCrontabField {

    public static final int MIN = 1;
    public static final int MAX = 31;

    public CrontabDayField(String fieldStr, List<Integer> fieldList) {
        super(fieldStr, fieldList);
    }

}
