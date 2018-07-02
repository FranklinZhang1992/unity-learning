package com.demo.rcv;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Random;

public class ResetCodeTemplate extends TemplateBase {

	private static final String SEED_BUFFER = "Hello_World";
	private int typeOffset; // Index: 0 - 3
	private ResetCodeType type; // Index: 4 - 11
	private String seed; // Index: 11 - 31
	private long version; // Index: 32 - 40
	private String resetCode;
	private String encryptedResetCode;

	public ResetCodeTemplate(String encryptedStr, String encryptionKey) {
		super(encryptedStr, encryptionKey);
	}

	public ResetCodeTemplate() {
		super();
	}

	public void init(String validationCode, String encryptionKey) {
		ResetCodeType type = validationCode == null ? ResetCodeType.EMAIL : ResetCodeType.SUPPORT;
		StringBuilder sb = new StringBuilder();
		Random random = new Random();
		int typeOffset = random.nextInt(TYPE_LENGTH - 1);
		sb.append("000" + typeOffset);
		char[] defaultTypeArray = getAes().genRandomString(TYPE_LENGTH).toCharArray();
		char[] typeArray = type.displayVal().toCharArray();
		defaultTypeArray[typeOffset] = typeArray[0];
		defaultTypeArray[typeOffset + 1] = typeArray[1];
		sb.append(defaultTypeArray);
		ValidationCodeTemplate vct = new ValidationCodeTemplate(validationCode, encryptionKey);
		sb.append(getResetCodeSeedByValidationCodeSeed(vct.getSeed() + SEED_BUFFER));
		sb.append(TEMPLATE_VERSION_STR);
		this.resetCode = sb.toString();
	}

	private String byte2Hex(byte[] bytes) {
		StringBuffer stringBuffer = new StringBuffer();
		String temp = null;
		for (int i = 0; i < bytes.length; i++) {
			temp = Integer.toHexString(bytes[i] & 0xFF);
			if (temp.length() == 1) {
				stringBuffer.append("0");
			}
			stringBuffer.append(temp);
		}
		return stringBuffer.toString();
	}

	private String getResetCodeSeedByValidationCodeSeed(String validationCodeSeed) {
		String encodeStr = "";
		try {
			MessageDigest messageDigest = MessageDigest.getInstance("SHA-256");
			messageDigest.update(validationCodeSeed.getBytes("UTF-8"));
			encodeStr = byte2Hex(messageDigest.digest());
		} catch (NoSuchAlgorithmException | UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		return encodeStr;
	}

	@Override
	protected void loadTypeOffset(String rawStr) {
		String offsetStr = loadGeneric(rawStr, TYPE_OFFSET_START_INDEX, TYPE_OFFSET_START_INDEX + 2);
		this.typeOffset = Integer.parseInt(offsetStr); // 0 - 6
	}

	@Override
	protected void loadType(String rawStr) {
		int typeStartIndex = this.typeOffset + TYPE_START_INDEX;
		String type = loadGeneric(rawStr, typeStartIndex, TYPE_LENGTH);
		this.type = ResetCodeType.fromValue(Integer.parseInt(type));
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

	public ResetCodeType getType() {
		return type;
	}

	public String getSeed() {
		return seed;
	}

	public long getVersion() {
		return version;
	}

	public String getResetCode() {
		return resetCode;
	}

	public String getEncryptedResetCode() {
		return encryptedResetCode;
	}

}
