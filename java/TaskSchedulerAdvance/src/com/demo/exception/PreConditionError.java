package com.demo.exception;

public class PreConditionError extends RuntimeException {

    public PreConditionError(String string) {
        super(string);
    }

    private static final long serialVersionUID = -8977113913428341905L;

}
