package com.demo.aes;

import java.nio.charset.StandardCharsets;
import java.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

public class AES {

	private static final String ALGORITHM = "AES";
	private static final String DEFAULT_KEY = "0000000000000000";
	private static final AES instance = new AES();

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

}