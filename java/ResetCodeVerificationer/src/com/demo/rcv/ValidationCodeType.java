package com.demo.rcv;

public enum ValidationCodeType {

	NON_EXIST_USER(1, "01"), NON_ADMIN_USER(2, "02"), ADMIN_USER(3, "03");

	private final int value;
	private final String displayVal;

	private ValidationCodeType(int value, String displayVal) {
		this.value = value;
		this.displayVal = displayVal;
	}

	public static ValidationCodeType fromValue(int value) {
		for (ValidationCodeType v : ValidationCodeType.values()) {
			if (v.value == value) {
				return v;
			}
		}
		throw new IllegalArgumentException(Integer.toString(value));
	}

	public int value() {
		return this.value;
	}

	public String displayVal() {
		return this.displayVal;
	}
}
