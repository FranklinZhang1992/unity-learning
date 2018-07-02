package com.demo.rcv;

public enum ResetCodeType {

	EMAIL(1, "01"), SUPPORT(2, "02");

	private final int value;
	private final String displayVal;

	private ResetCodeType(int value, String displayVal) {
		this.value = value;
		this.displayVal = displayVal;
	}

	public static ResetCodeType fromValue(int value) {
		for (ResetCodeType v : ResetCodeType.values()) {
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
