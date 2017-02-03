package com.demo.model;

import java.util.List;

public class CrontabMinuteField extends AbstractCrontabField {

    public static final int MIN = 0;
    public static final int MAX = 59;

    public CrontabMinuteField(String fieldStr, List<Integer> fieldList) {
        super(fieldStr, fieldList);
    }

}
