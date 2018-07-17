package com.demo.exception;

public class EncryptErrorException extends RuntimeException {

	public EncryptErrorException(String string) {
		super(string);
	}

	private static final long serialVersionUID = -2151001732013924183L;

}
