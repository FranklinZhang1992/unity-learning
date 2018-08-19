package com.demo.jwt;

import java.security.NoSuchAlgorithmException;
import java.util.UUID;

import io.jsonwebtoken.io.Decoders;

public class Main {

    protected static void testToken() throws NoSuchAlgorithmException {
        JwtManager manager = JwtManager.getInstance();
        String sid = UUID.randomUUID().toString();
        String token = manager.generate(sid);
        System.out.println("Token = " + token);

        String[] slices = token.split("\\.");
        for (String slice : slices) {
            System.out.println("Slice = " + slice);
            String s = new String(Decoders.BASE64URL.decode(slice));
            System.out.println(s);
        }
    }

    protected static void testVerification() throws NoSuchAlgorithmException {
        JwtManager manager = JwtManager.getInstance();
        manager.verify(
                "eyJhbGciOiJIUzI1NiJ9.eyJzaWQiOiJkZGZlNzRjYS03OTRlLTRjYWItYmU3Mi1iMTMxYjViNzBkNGEiLCJpYXQiOjE1MzM4ODExMjV9.2L_48_BXtolB_g23AAw7wJDSOX0weeAygTF0Gon6C91");
    }

    public static void main(String[] args) throws NoSuchAlgorithmException {
        testToken();
        // testVerification();
    }

}
