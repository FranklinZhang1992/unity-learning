import java.math.BigInteger;
import java.util.Random;

public class AESKeyGenerator {

	private static final char[] salt1 = "salt1".toCharArray();
	private static final char[] salt2 = "salt2".toCharArray();
	private static final char[] secret = "ABC".toCharArray();

	public AESKeyGenerator() {

	}
	
	public String generateKey() {
		return generateKey(null);
	}

	public String generateKey(String seed) {
		if (seed != null) {
			return seed;
		}
		return new BigInteger(128, new Random()).toString(32);
	}

	/**
	 * encryptMemoryBasic: Up to the specified amount of ebuffer bytes will be
	 * encrypted;
	 * 
	 * @param ebuffer
	 *            - buffer of memory with data to be encrypted
	 * @param n_bytes
	 *            - amount of bytes to encrypt in ebuffer
	 **/
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
	} // END OF ENCRYPTMEMORYBASIC

	/**
	 * decryptMemoryBasic: Up to the specified amount of ebuffer bytes will be
	 * decrypted;
	 *
	 * @param ebuffer
	 *            - buffer of memory with data to be decrypted
	 * @param n_bytes
	 *            - amount of bytes to decrypt in ebuffer
	 **/
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
	} // END OF DECRYPTMEMORYBASIC
}
