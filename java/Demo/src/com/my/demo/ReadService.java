package com.my.demo;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ReadService {

	private final String POOL = "/developer/test_pool/";
	private static ReadService instance;
	private static Map<String, List<Message>> cache = null;
	private static long cacheTimeMillis = 0;

	private ReadService() {
		FileReadService.init();
	}

	public static void init() {
		if (instance == null) {
			instance = new ReadService();
		}
		if (cache == null) {
			cache = new HashMap<String, List<Message>>();
		}
	}

	public static ReadService getInstance() {
		return instance;
	}

	private List<String> getAllDataFilePaths() {
		List<String> filePaths = new ArrayList<String>();
		File pool = new File(POOL);
		if (pool.exists() && pool.isDirectory()) {
			File[] files = pool.listFiles();
			for (File f : files) {
				filePaths.add(f.getName());
			}
		}
		return filePaths;
	}

	private boolean isCacheExist() {
		return !cache.isEmpty();
	}

	private Map<String, List<Message>> cacheRWHandler(String guid) {
		return cacheRWHandler(guid, null);
	}

	private Map<String, List<Message>> generateResultMap(String guid, Map<String, List<Message>> sourceMap) {
		Map<String, List<Message>> resultMap = new HashMap<String, List<Message>>();
		if (guid == null) {
			resultMap.putAll(sourceMap);
		} else {
			List<Message> msgs = new ArrayList<Message>();
			List<Message> sourceMsgs = sourceMap.get(guid);
			if (sourceMsgs != null) {
				msgs.addAll(sourceMsgs);
			}
			resultMap.put(guid, msgs);
		}
		return resultMap;
	}

	private synchronized Map<String, List<Message>> cacheRWHandler(String guid, Map<String, List<Message>> newCache) {
		Map<String, List<Message>> resultMap = null;

		if (newCache == null) {
			resultMap = generateResultMap(guid, cache);
		} else {
			cache.clear();
			cache.putAll(newCache);
			cacheTimeMillis = new Date().getTime();
			resultMap = generateResultMap(guid, cache);
		}
		return resultMap;
	}

	private boolean needRefresh(List<String> fileNames) {
		for (String fileName : fileNames) {
			File file = new File(POOL + fileName);
			if (file.lastModified() > cacheTimeMillis) {
				return true;
			}
		}
		return false;
	}

	private String purify(String rawContent) {
		if (rawContent == null) {
			return null;
		}
		return rawContent.substring(rawContent.indexOf("Result"));
	}

	private Message getMessageFromStr(String content) {
		if (content == null) {
			return null;
		}
		String[] items = content.split("\n");
		Message msg = new Message();
		for (String item : items) {
			if (item.startsWith("Result:")) {
				msg.setResult(item.substring(item.indexOf("Result:") + "Result:".length()));
			}
			if (item.startsWith("ErrorCode:")) {
				msg.setErrorCode(item.substring(item.indexOf("ErrorCode:") + "ErrorCode:".length()));
			}

			if (item.startsWith("DefaultMessage:")) {
				msg.setDefaultMessage(item.substring(item.indexOf("DefaultMessage:") + "DefaultMessage:".length()));

			}
			if (item.startsWith("MsgArgs:")) {
				msg.setArgs(item.substring(item.indexOf("MsgArgs:") + "MsgArgs:".length()));
			}
			if (item.startsWith("Timestamp:")) {
				msg.setTimestemp(Long.valueOf(item.substring(item.indexOf("Timestamp:") + "Timestamp:".length())));
			}
		}
		return msg;
	}

	private List<Message> loadMsgsById(String guid) {
		List<Message> msgs = new ArrayList<Message>();
		if (guid != null) {
			String path = POOL + guid;
			String allContent = FileReadService.getInstance().call(new FileInputer(path));
			allContent = purify(allContent);
			String[] contentArray = allContent.split(WriteService.BLOCK_END_CHARACTER_LINE);
			for (String content : contentArray) {
				msgs.add(getMessageFromStr(content));
			}
		}
		return msgs;
	}

	private Map<String, List<Message>> load(String guid) {
		Map<String, List<Message>> result = new HashMap<String, List<Message>>();
		if (guid == null) {
			List<String> fileNames = getAllDataFilePaths();
			for (String fileName : fileNames) {
				List<Message> msgs = loadMsgsById(fileName);
				result.put(fileName, msgs);
			}
		} else {
			List<Message> msgs = loadMsgsById(guid);
			result.put(guid, msgs);
		}
		return cacheRWHandler(guid, result);

	}

	public Map<String, List<Message>> read(String guid) {
		List<String> fileNames = getAllDataFilePaths();
		if (!isCacheExist() || needRefresh(fileNames)) {
			return load(guid);
		} else {
			return cacheRWHandler(guid);
		}
	}
}
