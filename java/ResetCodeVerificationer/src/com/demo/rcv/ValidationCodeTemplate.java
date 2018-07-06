package com.demo.rcv;

import java.util.Random;

public class ValidationCodeTemplate extends TemplateBase {
	private int typeOffset; // Index: 0 - 3
	private ValidationCodeType type; // Index: 4 - 11
	private String seed; // Index: 11 - 31
	private String validationCode;

	public ValidationCodeTemplate(String rawStr) {
		super(rawStr);
	}

	public ValidationCodeTemplate(ValidationCodeType type) {
		super();
		StringBuilder sb = new StringBuilder();
		Random random = new Random();
		int typeOffset = random.nextInt(TYPE_LENGTH - 1);
		sb.append("0" + typeOffset);
		char[] defaultTypeArray = getAes().genRandomString(TYPE_LENGTH).toCharArray();
		char[] typeArray = type.displayVal().toCharArray();
		defaultTypeArray[typeOffset] = typeArray[0];
		defaultTypeArray[typeOffset + 1] = typeArray[1];
		sb.append(defaultTypeArray);
		sb.append(getAes().genRandomString(SEED_LENGTH));
		this.validationCode = sb.toString();
	}

	@Override
	protected void loadTypeOffset(String rawStr) {
		String offsetStr = loadGeneric(rawStr, TYPE_OFFSET_START_INDEX, TYPE_OFFSET_LENGTH);
		this.typeOffset = Integer.parseInt(offsetStr); // 0 - 6
	}

	@Override
	protected void loadType(String rawStr) {
		int typeStartIndex = this.typeOffset + TYPE_START_INDEX;
		String type = loadGeneric(rawStr, typeStartIndex, 2);
		this.type = ValidationCodeType.fromValue(Integer.parseInt(type));
	}

	@Override
	protected void loadSeed(String rawStr) {
		this.seed = loadGeneric(rawStr, SEED_START_INDEX, SEED_LENGTH);
	}

	public int getTypeOffset() {
		return typeOffset;
	}

	public ValidationCodeType getType() {
		return type;
	}

	public String getSeed() {
		return seed;
	}

	public String getValidationCode() {
		return validationCode;
	}

}
