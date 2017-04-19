package com.my.demo;

public class FileWriterService {
	private static FileWriterService instance;

	private FileWriterService() {

	}

	public static void init() {
		if (instance == null) {
			instance = new FileWriterService();
		}
	}

	public static FileWriterService getInstance() {
		return instance;
	}

	public void call(FileOutputer fo, String content) {
		fo.write(content);
	}
}
