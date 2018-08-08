package com.demo.jwt;

import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.util.Date;

import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTVerificationException;
import com.auth0.jwt.interfaces.DecodedJWT;

public class JwtManager {
	private static final long MAX_INTERVAL = 1000 * 60 * 30;
	private RSAPublicKey publicKey;
	private RSAPrivateKey privateKey;
	private static JwtManager instance;

	public synchronized static JwtManager getInstance() throws NoSuchAlgorithmException {
		if (instance == null) {
			instance = new JwtManager();
		}
		return instance;
	}

	public JwtManager() throws NoSuchAlgorithmException {
		KeyPairGenerator generator = KeyPairGenerator.getInstance("RSA");
		generator.initialize(2048, new FixedSecureRandom());
		KeyPair keyPair = generator.generateKeyPair();

		publicKey = (RSAPublicKey) keyPair.getPublic();
		privateKey = (RSAPrivateKey) keyPair.getPrivate();
	}

	public String generate() throws NoSuchAlgorithmException {
		Algorithm algorithm = Algorithm.RSA256(publicKey, privateKey);
		String token = JWT.create().withAudience("userA").withIssuedAt(new Date()).sign(algorithm);
		return token;
	}

	public boolean verify(String token) {
		try {
			Algorithm algorithm = Algorithm.RSA256(publicKey, privateKey);
			JWTVerifier verifier = JWT.require(algorithm).withIssuer("userA").build();
			DecodedJWT jwt = verifier.verify(token);
			Date issuedDate = jwt.getIssuedAt();
			if ((System.currentTimeMillis() - issuedDate.getTime()) < MAX_INTERVAL) {
				System.err.println("Expired token");
				return true;
			}
		} catch (JWTVerificationException exception) {
			System.err.println("Invalid token");
		}
		return false;
	}
}
