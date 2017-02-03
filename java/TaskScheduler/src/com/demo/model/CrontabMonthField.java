package com.demo.model;

import java.util.List;

public class CrontabMonthField extends AbstractCrontabField {

    public static final int MIN = 1;
    public static final int MAX = 12;

    public CrontabMonthField(String fieldStr, List<Integer> fieldList) {
        super(fieldStr, fieldList);
    }

}
