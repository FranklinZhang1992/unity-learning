package com.my.demo;

import java.io.FileWriter;
import java.io.IOException;

public class FileOutputer {
	private final String POOL = "/developer/test_pool/";
	private String filePath = null;
	private boolean isAppend = false;

	public FileOutputer(String guid) {
		filePath = POOL + guid;
	}

	public FileOutputer(String guid, boolean append) {
		filePath = POOL + guid;
		isAppend = append;
	}

	public void write(String content) {
		FileWriter fw = null;
		try {
			fw = new FileWriter(filePath, isAppend);
			fw.write(content);
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				fw.flush();
				fw.close();
			} catch (IOException e) {
			}
		}
	}
}
