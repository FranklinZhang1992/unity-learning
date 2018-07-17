package com.demo.encoder;

public class Encryptor {

	private static final Encryptor _instance = new Encryptor();

	private Encryptor() {
	}

	public static Encryptor getInstance() {
		return _instance;
	}

	public byte[] encode(String systemUuid) {
		return null;
	}
}
