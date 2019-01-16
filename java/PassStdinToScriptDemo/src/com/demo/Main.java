package com.demo;

import java.io.File;
import java.nio.file.Files;
import java.util.Arrays;

public class Main {

	public static void main(String[] args) {
		String scriptPath = args[0];
		File scriptFile = new File(scriptPath);
		if (!scriptFile.exists()) {
			throw new RuntimeException("Script does not exist");
		}
		Files.write(new Path, bytes, options)
		SystemCommand.execute(Arrays.asList(scriptPath, ""))
	}

}
