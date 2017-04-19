package com.my.demo;

import java.io.File;
import java.util.Date;

public class WriteService {

	private final String POOL = "/developer/test_pool/";

	private static WriteService instance;

	private WriteService() {
		FileWriterService.init();
	}

	public static void init() {
		if (instance == null) {
			instance = new WriteService();
		}
	}

	public static WriteService getInstance() {
		return instance;
	}

	public static final String BLOCK_END_CHARACTER = "===============================================";
	public static final String BLOCK_END_CHARACTER_LINE = "===============================================\n";

	private String concatMessageArgs(final Object... messageArgs) {
		if (messageArgs == null) {
			return null;
		}
		StringBuilder sb = new StringBuilder();
		for (Object arg : messageArgs) {
			sb.append("[");
			sb.append(arg);
			sb.append("]");
		}
		return sb.toString();
	}

	private String buildLine(String key, String value) {
		return key + ":" + value + "\n";
	}

	private String buildResult(final String result) {
		return buildLine("Result", result);
	}

	private String buildErrorCode(final String errorCode) {
		return buildLine("ErrorCode", errorCode);
	}

	private String buildDefaultMessage(final String defaultMessage) {
		return buildLine("DefaultMessage", defaultMessage);
	}

	private String buildTimeStamp() {
		return buildLine("Timestamp", String.valueOf(new Date().getTime()));
	}

	private String buildMsgArgs(final Object... messageArgs) {
		String msgSring = concatMessageArgs(messageArgs);
		return buildLine("MsgArgs", msgSring);
	}

	private String buildBlock(final String result, final String errorCode, final String defaultMessage,
			final Object... messageArgs) {
		return buildResult(result) + buildErrorCode(errorCode) + buildDefaultMessage(defaultMessage)
				+ buildMsgArgs(messageArgs) + buildTimeStamp() + BLOCK_END_CHARACTER_LINE;
	}

	private void prepareDataFile(final String guid) {
		String dataFileName = POOL + guid;
		File dataFile = new File(dataFileName);
		if (!dataFile.exists()) {
			Date now = new Date();
			String title = "# Crontab execution history record file, created on " + now.toString() + "\n";

			FileWriterService.getInstance().call(new FileOutputer(guid), title);
		}
	}

	public void write(final String guid, final String result, final String errorCode, final String defaultMessage,
			final Object... messageArgs) {
		prepareDataFile(guid);
		String content = buildBlock(result, errorCode, defaultMessage, messageArgs);
		FileWriterService.getInstance().call(new FileOutputer(guid, true), content);
	}

}
