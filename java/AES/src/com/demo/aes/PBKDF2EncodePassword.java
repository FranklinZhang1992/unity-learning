package com.demo.aes;

import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public class PBKDF2EncodePassword {
    public static void main(String[] args) throws NoSuchAlgorithmException, InvalidKeySpecException {
        String originalPassword = "E98WGDE6UXKEX3W8H8266Q138R";

        String generatedSecuredPasswordHash = generateStorngPasswordHash(originalPassword);
        System.out.println("generatedSecuredPasswordHash = " + generatedSecuredPasswordHash);
        System.out.println("len = " + generatedSecuredPasswordHash.length());

        boolean matched = validatePassword("E98WGDE6UXKEX3W8H8266Q138R", generatedSecuredPasswordHash);
        System.out.println(matched);

        matched = validatePassword("E98WGDE6UXKEX3W8H8266Q138R", generatedSecuredPasswordHash);
        System.out.println(matched);
    }

    private static String generateStorngPasswordHash(String password)
            throws NoSuchAlgorithmException, InvalidKeySpecException {
        int iterations = 40000;
        char[] chars = password.toCharArray();
        byte[] salt = getSalt();

        PBEKeySpec spec = new PBEKeySpec(chars, salt, iterations, 64);
        SecretKeyFactory skf = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
        byte[] hash = skf.generateSecret(spec).getEncoded();
        return base64Encode(hash);
    }

    private static byte[] getSalt() throws NoSuchAlgorithmException {
        return new String("161a9d1c6b434e998e52e5be7356e438").getBytes();
    }

    private static String base64Encode(byte[] bytes) {
        return Base64.getEncoder().encodeToString(bytes);
    }

    private static boolean validatePassword(String originalPassword, String storedPassword)
            throws NoSuchAlgorithmException, InvalidKeySpecException {
        String expected = generateStorngPasswordHash(originalPassword);
        return expected.equals(storedPassword);
    }

}
