package com.demo.rcv;

import com.demo.aes.AES;

public abstract class TemplateBase {
	private AES aes = AES.getInstance();

	protected static final int TYPE_OFFSET_START_INDEX = 0;
	protected static final int TYPE_OFFSET_LENGTH = 4;
	protected static final int TYPE_START_INDEX = 4;
	protected static final int TYPE_LENGTH = 8;
	protected static final int SEED_START_INDEX = 12;
	protected static final int SEED_LENGTH = 20;
	protected static final int VERSION_START_INDEX = 32;
	protected static final int VERSION_LENGTH = 8;
	protected static final String TEMPLATE_VERSION_STR = "00000001";
	protected String encryptionKey;

	public TemplateBase(String encryptedStr, String encryptionKey) {
		try {
			this.encryptionKey = encryptionKey;
			String rawStr = getAes().decrypt(encryptionKey, encryptedStr);
			loadTypeOffset(rawStr);
			loadType(rawStr);
			loadSeed(rawStr);
			loadVersion(rawStr);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public TemplateBase() {
	}

	protected String loadGeneric(String rawStr, int startIndex, int len) {
		return rawStr.substring(startIndex, startIndex + len);
	}

	protected abstract void loadTypeOffset(String rawStr);

	protected abstract void loadType(String rawStr);

	protected abstract void loadSeed(String rawStr);

	protected abstract void loadVersion(String rawStr);

	protected AES getAes() {
		return aes;
	}

	protected String getEncryptionKey() {
		return encryptionKey;
	}

}
