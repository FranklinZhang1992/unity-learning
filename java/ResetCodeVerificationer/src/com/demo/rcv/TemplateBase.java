package com.demo.rcv;

import com.demo.aes.AES;

public abstract class TemplateBase {
	private AES aes = AES.getInstance();

	protected static final int TYPE_OFFSET_START_INDEX = 0;
	protected static final int TYPE_OFFSET_LENGTH = 2;
	protected static final int TYPE_START_INDEX = 2;
	protected static final int TYPE_LENGTH = 2;
	protected static final int SEED_START_INDEX = 4;
	protected static final int SEED_LENGTH = 6;

	public TemplateBase(String rawStr) {
		loadTypeOffset(rawStr);
		loadType(rawStr);
		loadSeed(rawStr);
	}

	public TemplateBase() {
	}

	protected String loadGeneric(String rawStr, int startIndex, int len) {
		return rawStr.substring(startIndex, startIndex + len);
	}

	protected abstract void loadTypeOffset(String rawStr);

	protected abstract void loadType(String rawStr);

	protected abstract void loadSeed(String rawStr);

	protected AES getAes() {
		return aes;
	}

}
