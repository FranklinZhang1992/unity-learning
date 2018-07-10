package com.demo.aes;

import java.util.Random;

public class AESKeyGenerator {

	private static final char[] salt1 = "salt1".toCharArray();
	private static final char[] salt2 = "salt2".toCharArray();
	private static final char[] secret = "ABC".toCharArray();

	private static final int FIRST_UPPER_CASE_LETTER_ASCII = 65;
	private static final int FIRST_LOWER_CASE_LETTER_ASCII = 97;

	public AESKeyGenerator() {

	}

	private String randomString(int len) {
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

	public String generateKey() {
		return generateKey(null);
	}

	public String generateKey(String seed) {
		if (seed != null) {
			return seed;
		}
		Random random = new Random();
		int len = random.nextInt(10) + 10; // 10 ~ 20

		return randomString(len);
	}

	public String getEncryptedKey(String rawKey) {
		char[] keyByte = rawKey.toCharArray();
		encryptMemoryBasic(keyByte, keyByte.length);
		return new String(keyByte);
	}

	public String getDecryptedKey(String encryptedKey) {
		char[] keyByte = encryptedKey.toCharArray();
		decryptMemoryBasic(keyByte, keyByte.length);
		return new String(keyByte);
	}

	private void encryptMemoryBasic(char[] ebuffer, int n_bytes) {
		// First Encrypt Step: salt the data to be encrypted
		for (int i = 0; i < n_bytes; i++)
			ebuffer[i] = (char) (ebuffer[i] ^ salt1[i % salt1.length]);
		// Second Encrypt Step: encrypt data with secret
		for (int i = 0; i < n_bytes; i++)
			ebuffer[i] = (char) (ebuffer[i] ^ secret[i % secret.length]);
		// Third Encrypt Step: add second layer of salt
		for (int i = 0; i < n_bytes; i++)
			ebuffer[i] = (char) (ebuffer[i] ^ salt2[i % salt2.length]);
	}

	private void decryptMemoryBasic(char[] ebuffer, int n_bytes) {
		// First Decrypt Step: undo 2nd salt
		for (int i = 0; i < n_bytes; i++)
			ebuffer[i] = (char) (ebuffer[i] ^ salt2[i % salt2.length]);
		// Second Decrypt Step: undo secret
		for (int i = 0; i < n_bytes; i++)
			ebuffer[i] = (char) (ebuffer[i] ^ secret[i % secret.length]);
		// Third Decrypt Step: undo 1st layer of salt
		for (int i = 0; i < n_bytes; i++)
			ebuffer[i] = (char) (ebuffer[i] ^ salt1[i % salt1.length]);
	}
}
