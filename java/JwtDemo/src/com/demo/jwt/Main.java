package com.demo.jwt;

import java.security.NoSuchAlgorithmException;

public class Main {

	public static void main(String[] args) throws NoSuchAlgorithmException {
		JwtManager manager = JwtManager.getInstance();
		String token = manager.generate();
		System.out.println("Token = " + token);
		if (manager.verify(token)) {
			System.out.println("Valid token");
		} else {
			System.err.println("Invalid token");
		}

	}

}
