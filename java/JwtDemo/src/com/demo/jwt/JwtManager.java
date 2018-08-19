package com.demo.jwt;

import java.security.Key;
import java.security.NoSuchAlgorithmException;
import java.util.Date;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;

public class JwtManager {
    private static final long MAX_INTERVAL = 1000 * 60 * 30;
    private static JwtManager instance;

    private Key key;

    public synchronized static JwtManager getInstance() throws NoSuchAlgorithmException {
        if (instance == null) {
            instance = new JwtManager();
        }
        return instance;
    }

    public JwtManager() throws NoSuchAlgorithmException {
        key = Keys.hmacShaKeyFor("677d150f153f46f3afb49412755951ae".getBytes());
    }

    public String generate(String sid) {
        return Jwts.builder().claim("sid", sid).setIssuedAt(new Date()).signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    public boolean verify(String token) {

        Jws<Claims> jws = null;
        try {
            jws = Jwts.parser().requireSubject("sid").setSigningKey(key).parseClaimsJws(token);
        } catch (JwtException e) {
            System.err.println(e.getMessage());
        }
        if (jws == null) {
            return false;
        }
        Date issuedAt = jws.getBody().getIssuedAt();
        if ((System.currentTimeMillis() - issuedAt.getTime()) > MAX_INTERVAL) {
            throw new RuntimeException("Token expired");
        }
        return true;
    }
}
