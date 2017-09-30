package com.demo.model;

/**
 * Class for storing crontab trigger hour field
 *
 */
public class CrontabHourField extends AbstractCrontabField {

	/** Hour in a day starts at 0 and ends at 23 */
	public static final int MIN = 0;
	public static final int MAX = 23;
	public static final String FIELD_NAME = "hour";

	public CrontabHourField(final String fieldStr) {
		super(fieldStr, FIELD_NAME);
		validateField(fieldStr);
	}

	@Override
	protected void validateField(final String fieldStr) {
		validateCommonField(fieldStr, MIN, MAX);
	}

}
