package com.demo.jwt;

import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;

public class JwtManager {
    private static final long MAX_INTERVAL = 1000 * 60 * 30;
    private static JwtManager instance;

    private KeyPair keyPair;

    public synchronized static JwtManager getInstance() throws NoSuchAlgorithmException {
        if (instance == null) {
            instance = new JwtManager();
        }
        return instance;
    }

    public JwtManager() throws NoSuchAlgorithmException {
        KeyPairGenerator generator = KeyPairGenerator.getInstance("RSA");
        generator.initialize(2048, new FixedSecureRandom());
        keyPair = generator.generateKeyPair();

    }

    public String generate() {
        return Jwts.builder().setSubject("Joe").signWith(keyPair.getPrivate()).compact();
    }

    // public boolean verify(String token) {
    // }
}
