package com.demo.aes;

import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.Random;

import com.demo.base32.CustomizedBase32;

public class AESKeyGenerator {

    private static final char[] salt1 = "salt11".toCharArray();
    private static final char[] salt2 = "salt22".toCharArray();
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

    public String format(String raw) {
        if (raw.length() != 24) {
            throw new RuntimeException("Invalid length " + raw.length());
        }
        StringBuilder sb = new StringBuilder();
        List<String> list = new ArrayList<String>();
        int i = 0;
        for (char c : raw.toCharArray()) {
            i++;
            sb.append(c);
            if (i % 6 == 0) {
                list.add(sb.toString());
                sb = new StringBuilder();
            }
        }
        return String.join("-", list);
    }

    protected static void test() {
        String s1 = "161a9d1c6b4";
        String timeHex = Long.toHexString(System.currentTimeMillis());
        System.out.println("timeHex = " + timeHex);
        String s2 = timeHex.substring(timeHex.length() - 4, timeHex.length());
        String data = s1 + s2;
        System.out.println("data = " + data);
        AESKeyGenerator ag = new AESKeyGenerator();
        char[] buffer = data.toCharArray();
        ag.encryptMemoryBasic(buffer, buffer.length);
        System.out.println("Encrypted len: " + buffer.length);
        byte[] bytes = String.valueOf(buffer).getBytes();
        String stdEncoded = Base64.getEncoder().encodeToString(bytes);
        String encoded = CustomizedBase32.getEncoder().encodeToString(bytes);
        System.out.println("STD Encoded: " + stdEncoded);
        System.out.println("STD Encoded len: " + stdEncoded.length());
        System.out.println("Encoded: " + encoded);
        System.out.println("Encoded len: " + encoded.length());
        System.out.println("Formatted: " + ag.format(encoded));
    }

    protected static void test2() {
        AESKeyGenerator ag = new AESKeyGenerator();

        String s1 = "6afa31dba37" + "1111";
        String s2 = "6afa31dba37" + "4444";

        char[] buffer1 = s1.toCharArray();
        char[] buffer2 = s2.toCharArray();

        ag.encryptMemoryBasic(buffer1, buffer1.length);
        ag.encryptMemoryBasic(buffer2, buffer2.length);

        System.out.println(Base64.getEncoder().encodeToString(String.valueOf(buffer1).getBytes()));
        System.out.println(Base64.getEncoder().encodeToString(String.valueOf(buffer2).getBytes()));
    }

    public static void main(String[] args) {
        test2();
    }
}
