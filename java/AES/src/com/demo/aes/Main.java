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

	protected static void test2(String plainText) throws Exception {
		System.out.println("original string: " + plainText);
		String key = generateKey();
		System.out.println("Generated key: " + key);
		String encryptedStr = aes.encryptWithCustomizedBase32(key, plainText);
		System.out.println("ecrypted string: " + encryptedStr);
		String decryptedStr = aes.decryptWithCustomizedBase32(key, encryptedStr);
		System.out.println("decrypted string: " + decryptedStr);
	}

	protected static void test3(String plainText) throws Exception {
		System.out.println("original string: " + plainText);
		String key = generateKey();
		System.out.println("Generated key: " + key);
		String encryptedStr = aes.encrypt(key, plainText);
		System.out.println("ecrypted string (Base64): " + encryptedStr);
		String decryptedStr = aes.decrypt(key, encryptedStr);
		System.out.println("decrypted string (Base64): " + decryptedStr);
		encryptedStr = aes.encryptWithCustomizedBase32(key, plainText);
		System.out.println("ecrypted string (Base32): " + encryptedStr);
		decryptedStr = aes.decryptWithCustomizedBase32(key, encryptedStr);
		System.out.println("decrypted string (Base32): " + decryptedStr);
	}

	public static void main(String[] args) throws Exception {
		String plainText = "Hello world!";
		test3(plainText);
	}

}
