package com.demo.rcv;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.Map;

public class ResetCodeTemplate extends TemplateBase {

	private int typeOffset; // Index: 0 - 3
	private ResetCodeType type; // Index: 4 - 11
	private String seed; // Index: 11 - 31
	private String resetCode;
	private static final int SEED_EXPECTED_LEN = 16;
	private static final char[] fillCharArray = "Hello World!".toCharArray();

	private static final Map<String, String> dictionary = new HashMap<String, String>() {

		private static final long serialVersionUID = 8370626826215433821L;

		{
			put("0", "K");
			put("1", "E");
			put("2", "9");
			put("3", "R");
			put("4", "P");
			put("5", "a");
			put("6", "B");
			put("7", "0");
			put("8", "c");
			put("9", "i");
			put("A", "V");
			put("B", "j");
			put("C", "Y");
			put("D", "O");
			put("E", "U");
			put("F", "k");
			put("G", "h");
			put("H", "q");
			put("I", "l");
			put("J", "W");
			put("K", "m");
			put("L", "S");
			put("M", "k");
			put("N", "9");
			put("O", "i");
			put("P", "O");
			put("Q", "0");
			put("R", "t");
			put("S", "g");
			put("T", "N");
			put("U", "w");
			put("V", "4");
			put("W", "B");
			put("X", "H");
			put("Y", "V");
			put("Z", "a");
			put("a", "h");
			put("b", "D");
			put("c", "k");
			put("d", "w");
			put("e", "z");
			put("f", "5");
			put("g", "k");
			put("h", "A");
			put("i", "6");
			put("j", "1");
			put("k", "6");
			put("l", "1");
			put("m", "q");
			put("n", "6");
			put("o", "q");
			put("p", "8");
			put("q", "u");
			put("r", "U");
			put("s", "n");
			put("t", "I");
			put("u", "7");
			put("v", "F");
			put("w", "W");
			put("x", "B");
			put("y", "d");
			put("z", "y");

		}
	};

	private static final Map<String, String> dictionary2 = new HashMap<String, String>() {

		private static final long serialVersionUID = 8370626826215433821L;

		{
			put("0", "w");
			put("1", "H");
			put("2", "o");
			put("3", "a");
			put("4", "Y");
			put("5", "x");
			put("6", "r");
			put("7", "4");
			put("8", "q");
			put("9", "Z");
			put("A", "X");
			put("B", "L");
			put("C", "Q");
			put("D", "8");
			put("E", "8");
			put("F", "x");
			put("G", "0");
			put("H", "u");
			put("I", "L");
			put("J", "0");
			put("K", "1");
			put("L", "8");
			put("M", "k");
			put("N", "p");
			put("O", "W");
			put("P", "Y");
			put("Q", "H");
			put("R", "3");
			put("S", "U");
			put("T", "d");
			put("U", "d");
			put("V", "T");
			put("W", "J");
			put("X", "H");
			put("Y", "i");
			put("Z", "B");
			put("a", "q");
			put("b", "b");
			put("c", "I");
			put("d", "f");
			put("e", "5");
			put("f", "Y");
			put("g", "W");
			put("h", "B");
			put("i", "5");
			put("j", "Z");
			put("k", "p");
			put("l", "u");
			put("m", "R");
			put("n", "J");
			put("o", "0");
			put("p", "K");
			put("q", "j");
			put("r", "I");
			put("s", "e");
			put("t", "Q");
			put("u", "q");
			put("v", "a");
			put("w", "d");
			put("x", "X");
			put("y", "c");
			put("z", "M");

		}
	};

	public ResetCodeTemplate(String rawStr) {
		super(rawStr);
	}

	public ResetCodeTemplate() {
		super();
	}

	public void init(String validationCode) {
		StringBuilder sb = new StringBuilder();
		ValidationCodeTemplate vct = new ValidationCodeTemplate(validationCode);
		sb.append(getResetCodeSeedByValidationCodeSeed(getEvolvedSeed(vct)));
		this.resetCode = sb.toString();
	}

	private String getEvolvedSeed(ValidationCodeTemplate vct) {
		StringBuilder sb = new StringBuilder();
		String originalSeed = vct.getSeed();
		int origSeedLen = originalSeed.length();
		System.out.println("OriginalSeed: " + originalSeed);
		for (int i = 0; i < SEED_EXPECTED_LEN; i++) {
			if (i < origSeedLen) {
				sb.append(dictionary.get(String.valueOf(originalSeed.charAt(i))));
			} else {
				String key = String.valueOf(fillCharArray[i % fillCharArray.length]);
				sb.append(dictionary2.get(key));
			}
		}
		System.out.println("EvolvedSeed: " + sb.toString());
		return sb.toString();
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
			MessageDigest messageDigest = MessageDigest.getInstance("MD5");
			messageDigest.update(validationCodeSeed.getBytes("UTF-8"));
			encodeStr = byte2Hex(messageDigest.digest());
		} catch (NoSuchAlgorithmException | UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		return encodeStr;
	}

	@Override
	protected void loadTypeOffset(String rawStr) {
		String offsetStr = loadGeneric(rawStr, TYPE_OFFSET_START_INDEX, 2);
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

	public int getTypeOffset() {
		return typeOffset;
	}

	public ResetCodeType getType() {
		return type;
	}

	public String getSeed() {
		return seed;
	}

	public String getResetCode() {
		return resetCode;
	}

}
