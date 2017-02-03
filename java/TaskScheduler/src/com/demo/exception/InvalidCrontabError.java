package com.demo.exception;

import java.util.ArrayList;
import java.util.List;

public class InvalidCrontabError extends RuntimeException {

    private static final long serialVersionUID = 1449956491008964067L;

    private String key;
    private List<String> params = new ArrayList<String>();

    public InvalidCrontabError(String defaultMessage, String key, String... args) {
        super(defaultMessage);
        this.key = key;
        for (int i = 0; i < args.length; i++) {
            params.add(args[i]);
        }
    }

    public String getKey() {
        return key;
    }

    public List<String> getParams() {
        return params;
    }

}
