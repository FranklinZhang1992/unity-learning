import java.nio.charset.StandardCharsets;
import java.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

public class AES {

	private static final String ALGORITHM = "AES";
	private static final int SECRET_KEY_LENGTH = 128;

	/**
	 * Extent the key to 128 bit
	 * 
	 * @param key
	 * @return A 128 bit key
	 */
	protected static byte[] formatSecretKey(String key) {
		byte[] keyByte = key.getBytes(StandardCharsets.UTF_8);
		if (keyByte.length < SECRET_KEY_LENGTH) {

		}
		// for ()
		return keyByte;
	}

	protected static String encrypt(String key, String plainText) throws Exception {
		byte[] formattedKey = formatSecretKey(key);
		SecretKeySpec secretKey = new SecretKeySpec(formattedKey, ALGORITHM);
		Cipher cipher = Cipher.getInstance(ALGORITHM);
		cipher.init(Cipher.ENCRYPT_MODE, secretKey);
		byte[] encrypted = cipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8));
		return Base64.getEncoder().encodeToString(encrypted);
	}

	protected static String decrypt(String key, String cipherText) throws Exception {
		byte[] formattedKey = formatSecretKey(key);
		SecretKeySpec secretKey = new SecretKeySpec(formattedKey, ALGORITHM);
		Cipher cipher = Cipher.getInstance(ALGORITHM);
		cipher.init(Cipher.DECRYPT_MODE, secretKey);
		byte[] original = cipher.doFinal(Base64.getDecoder().decode(cipherText.getBytes(StandardCharsets.UTF_8)));
		return new String(original);
	}

	public static void main(String[] args) throws Exception {
		String encryptionKey = "MZygpewJsCpRrfOr";
		// String encryptionKey = "fnki4obct0n8d";
		String plainText = "Hello world!";

		System.out.println("original string: " + plainText);
		String cipherText = encrypt(encryptionKey, plainText);
		System.out.println("ecrypted string: " + cipherText);
		String decryptedCipherText = decrypt(encryptionKey, cipherText);
		System.out.println("decrypted string: " + decryptedCipherText);
	}
}