package com.demo.rcv;

import java.util.Random;

public class ValidationCodeTemplate extends TemplateBase {
	private int typeOffset; // Index: 0 - 3
	private ValidationCodeType type; // Index: 4 - 11
	private String seed; // Index: 11 - 31
	private long version; // Index: 32 - 40
	private String validationCode;
	private String encryptedValidationCode;

	public ValidationCodeTemplate(String encryptedStr, String encryptionKey) {
		super(encryptedStr, encryptionKey);
	}

	public ValidationCodeTemplate(ValidationCodeType type, String encryptionKey) {
		super();
		StringBuilder sb = new StringBuilder();
		Random random = new Random();
		int typeOffset = random.nextInt(TYPE_LENGTH - 1);
		sb.append("000" + typeOffset);
		char[] defaultTypeArray = getAes().genRandomString(TYPE_LENGTH).toCharArray();
		char[] typeArray = type.displayVal().toCharArray();
		defaultTypeArray[typeOffset] = typeArray[0];
		defaultTypeArray[typeOffset + 1] = typeArray[1];
		sb.append(defaultTypeArray);
		sb.append(getAes().genRandomString(SEED_LENGTH));
		sb.append(TEMPLATE_VERSION_STR);
		this.validationCode = sb.toString();
		try {
			this.encryptedValidationCode = getAes().encrypt(encryptionKey, this.validationCode);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	protected void loadTypeOffset(String rawStr) {
		String offsetStr = loadGeneric(rawStr, TYPE_OFFSET_START_INDEX, TYPE_OFFSET_LENGTH);
		this.typeOffset = Integer.parseInt(offsetStr); // 0 - 6
	}

	@Override
	protected void loadType(String rawStr) {
		int typeStartIndex = this.typeOffset + TYPE_START_INDEX;
		String type = loadGeneric(rawStr, typeStartIndex, typeStartIndex + 2);
		this.type = ValidationCodeType.fromValue(Integer.parseInt(type));
	}

	@Override
	protected void loadSeed(String rawStr) {
		this.seed = loadGeneric(rawStr, SEED_START_INDEX, SEED_LENGTH);
	}

	@Override
	protected void loadVersion(String rawStr) {
		String versionStr = loadGeneric(rawStr, VERSION_START_INDEX, VERSION_LENGTH);
		this.version = Long.parseLong(versionStr);
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

	public long getVersion() {
		return version;
	}

	public String getValidationCode() {
		return validationCode;
	}

	public String getEncryptedValidationCode() {
		return encryptedValidationCode;
	}

}
