package com.demo.jwt;

import java.security.NoSuchAlgorithmException;

public class Main {

    public static void main(String[] args) throws NoSuchAlgorithmException {
        JwtManager manager = JwtManager.getInstance();
        String token = manager.generate();
        System.out.println("Token = " + token);

    }

}
