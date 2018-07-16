package com.demo.aes;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.AlgorithmParameters;
import java.security.GeneralSecurityException;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.KeySpec;
import java.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;

public class ProtectedConfigFile {

    public static void main(String[] args) throws Exception {
        String password = "161a9d1c6b434e998e52e5be7356e438";

        // The salt (probably) can be stored along with the encrypted data

        String timeHex = Long.toHexString(System.currentTimeMillis());
        String data = timeHex.substring(timeHex.length() - 8, timeHex.length()) + "_p_10033";
        data = "TC3E98vG_p_10033";

        byte[] salt = new String("ze_p_10033").getBytes();
        byte[] saltRaw = new String("161a9d1c6b434e998e52e5be7356e438").getBytes();
        byte[] salt2 = new byte[16];
        for (int i = 0; i < 16; i++) {
            salt2[i] = saltRaw[i];
        }
        System.out.println("salt1 len = " + salt.length);
        System.out.println("salt2 len = " + salt2.length);

        // Decreasing this speeds down startup time and can be useful during
        // testing, but it also makes it easier for brute force attackers
        int iterationCount = 32768;
        // Other values give me java.security.InvalidKeyException: Illegal key
        // size or default parameters
        int keyLength = 128;
        SecretKeySpec key = createSecretKey(password.toCharArray(), salt, iterationCount, keyLength);

        String originalPassword = data;
        System.out.println("Original password: " + originalPassword);
        System.out.println("Original password length: " + originalPassword.length());
        String encryptedPassword = encrypt(originalPassword, key, salt2);
        System.out.println("Encrypted password: " + encryptedPassword);
        System.out.println("Encrypted password length: " + encryptedPassword.length());
        String decryptedPassword = decrypt(encryptedPassword, key, salt2);
        System.out.println("Decrypted password: " + decryptedPassword);
    }

    private static SecretKeySpec createSecretKey(char[] password, byte[] salt, int iterationCount, int keyLength)
            throws NoSuchAlgorithmException, InvalidKeySpecException {
        SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
        KeySpec keySpec = new PBEKeySpec(password, salt, iterationCount, keyLength);
        SecretKey keyTmp = keyFactory.generateSecret(keySpec);
        return new SecretKeySpec(keyTmp.getEncoded(), "AES");
    }

    private static String encrypt(String property, SecretKeySpec key, byte[] salt)
            throws GeneralSecurityException, UnsupportedEncodingException {
        Cipher pbeCipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        IvParameterSpec ivspec = new IvParameterSpec(salt);
        pbeCipher.init(Cipher.ENCRYPT_MODE, key, ivspec);
        AlgorithmParameters parameters = pbeCipher.getParameters();
        IvParameterSpec ivParameterSpec = parameters.getParameterSpec(IvParameterSpec.class);
        byte[] cryptoText = pbeCipher.doFinal(property.getBytes("UTF-8"));
        byte[] iv = ivParameterSpec.getIV();
        System.out.println("iv len = " + iv.length);
        // return base64Encode(iv) + ":" + base64Encode(cryptoText);
        return base64Encode(cryptoText);
    }

    private static String base64Encode(byte[] bytes) {
        return Base64.getEncoder().encodeToString(bytes);
    }

    private static String decrypt(String string, SecretKeySpec key, byte[] salt)
            throws GeneralSecurityException, IOException {
        // String iv = string.split(":")[0];
        // String property = string.split(":")[1];
        Cipher pbeCipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        IvParameterSpec ivspec = new IvParameterSpec(salt);
        pbeCipher.init(Cipher.DECRYPT_MODE, key, ivspec);
        return new String(pbeCipher.doFinal(base64Decode(string)), "UTF-8");
    }

    private static byte[] base64Decode(String property) throws IOException {
        return Base64.getDecoder().decode(property);
    }
}