package com.demo.aes;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Random;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

import com.demo.base32.CustomizedBase32;

public class AES {

	private static final String ALGORITHM = "AES";
	private static final String DEFAULT_KEY = "0000000000000000";
	private static final AES instance = new AES();
	private static final int FIRST_LOWER_CASE_LETTER_ASCII = 65;
	private static final int FIRST_UPPER_CASE_LETTER_ASCII = 97;

	private AES() {
	}

	public static AES getInstance() {
		return instance;
	}

	/**
	 * Extent the key to 128 bit
	 * 
	 * @param key
	 * @return A 128 bit key
	 */
	public byte[] formatSecretKey(String key) {
		byte[] defaultKeyByte = DEFAULT_KEY.getBytes(StandardCharsets.UTF_8);
		byte[] keyByte = key.getBytes(StandardCharsets.UTF_8);
		int defaultKeyByteLen = defaultKeyByte.length;
		int keyByteLen = keyByte.length;

		for (int i = 0; i < defaultKeyByteLen; i++) {
			if (i < keyByteLen) {
				defaultKeyByte[i] = keyByte[i];
			}
		}

		return defaultKeyByte;
	}

	public String encrypt(String key, String plainText) throws Exception {
		byte[] formattedKey = formatSecretKey(key);
		SecretKeySpec secretKey = new SecretKeySpec(formattedKey, ALGORITHM);
		Cipher cipher = Cipher.getInstance(ALGORITHM);
		cipher.init(Cipher.ENCRYPT_MODE, secretKey);
		byte[] encrypted = cipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8));
		return Base64.getEncoder().encodeToString(encrypted);
	}

	public String decrypt(String key, String cipherText) throws Exception {
		byte[] formattedKey = formatSecretKey(key);
		SecretKeySpec secretKey = new SecretKeySpec(formattedKey, ALGORITHM);
		Cipher cipher = Cipher.getInstance(ALGORITHM);
		cipher.init(Cipher.DECRYPT_MODE, secretKey);
		byte[] original = cipher.doFinal(Base64.getDecoder().decode(cipherText.getBytes(StandardCharsets.UTF_8)));
		return new String(original);
	}

	public String encryptWithCustomizedBase32(String key, String plainText) throws Exception {
		byte[] formattedKey = formatSecretKey(key);
		SecretKeySpec secretKey = new SecretKeySpec(formattedKey, ALGORITHM);
		Cipher cipher = Cipher.getInstance(ALGORITHM);
		cipher.init(Cipher.ENCRYPT_MODE, secretKey);
		byte[] encrypted = cipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8));
		return CustomizedBase32.getEncoder().encodeToString(encrypted);
	}

	public String decryptWithCustomizedBase32(String key, String cipherText) throws Exception {
		byte[] formattedKey = formatSecretKey(key);
		SecretKeySpec secretKey = new SecretKeySpec(formattedKey, ALGORITHM);
		Cipher cipher = Cipher.getInstance(ALGORITHM);
		cipher.init(Cipher.DECRYPT_MODE, secretKey);
		byte[] original = cipher
				.doFinal(CustomizedBase32.getDecoder().decode(cipherText.getBytes(StandardCharsets.UTF_8)));
		return new String(original);
	}

	public String genRandomString(int len) {
		Random random = new Random();
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < len; i++) {
			boolean isChar = (random.nextInt(2) % 2 == 0);
			if (isChar) {
				int firstLetterAscii = random.nextInt(2) % 2 == 0 ? FIRST_LOWER_CASE_LETTER_ASCII
						: FIRST_UPPER_CASE_LETTER_ASCII;
				sb.append((char) (firstLetterAscii + random.nextInt(26)));
			} else {
				sb.append(Integer.toString(random.nextInt(10)));
			}
		}
		return sb.toString();
	}

}