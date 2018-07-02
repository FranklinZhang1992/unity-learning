package com.demo.aes;

public class Main {

	private static AES aes = AES.getInstance();

	protected static String generateKey() {
		AESKeyGenerator generator = new AESKeyGenerator();
		String key = generator.generateKey();
		return key;
	}

	protected static void test(String plainText) throws Exception {
		System.out.println("original string: " + plainText);
		String key = generateKey();
		System.out.println("Generated key: " + key);
		String encryptedStr = aes.encrypt(key, plainText);
		System.out.println("ecrypted string: " + encryptedStr);
		String decryptedStr = aes.decrypt(key, encryptedStr);
		System.out.println("decrypted string: " + decryptedStr);
	}

	public static void main(String[] args) throws Exception {
		String plainText = "Hello world!";
		test(plainText);
		test(plainText);
		test(plainText);
		test(plainText);
	}

}
