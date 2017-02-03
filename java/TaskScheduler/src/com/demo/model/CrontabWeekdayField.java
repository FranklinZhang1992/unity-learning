package com.demo.model;

import java.util.Collections;
import java.util.List;

public class CrontabWeekdayField extends AbstractCrontabField {

    public static final int MIN = 0;
    public static final int MAX = 7;

    public CrontabWeekdayField(String fieldStr, List<Integer> fieldList) {
        super(fieldStr, fieldList);
        if (fieldList.contains(7)) {
            fieldList.remove(fieldList.indexOf(7));
            if (!fieldList.contains(0)) {
                fieldList.add(0);
                Collections.sort(fieldList);
            }
        }
    }

}
