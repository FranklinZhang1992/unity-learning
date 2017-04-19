package com.my.demo;

public class FileReadService {
	private static FileReadService instance;

	private FileReadService() {

	}

	public static void init() {
		if (instance == null) {
			instance = new FileReadService();
		}
	}

	public static FileReadService getInstance() {
		return instance;
	}

	public String call(FileInputer fi) {
		return fi.read();
	}
}
