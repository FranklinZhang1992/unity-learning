package com.demo.base32;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;

public class Main {

	protected static void normalTest(String s) {
		System.out.println("Encoding for " + s);
		String encoded = CustomizedBase32.getEncoder().encodeToString(s.getBytes());
		System.out.println("Encoded: " + encoded);
		String decoded = CustomizedBase32.getDecoder().decodeToString(encoded);
		System.out.println("Decoded: " + decoded);
	}

	protected static void execptionTest(String encoded) {
		try {
			System.out.println("Decoding for " + encoded);
			String decoded = CustomizedBase32.getDecoder().decodeToString(encoded);
			System.out.println("Decoded: " + decoded);
		} catch (Exception e) {
			System.out.println("[Fail] " + e);
		}
	}

	protected static void test1() {
		normalTest("a");
		normalTest("ab");
		normalTest("abc");
		normalTest("abcd");
		normalTest("abcde");
		normalTest("abcdef");
	}

	protected static void test2() {
		execptionTest("Z");
		execptionTest("ZZ");
		execptionTest("CZ");
		execptionTest("C4ZZZ");
		execptionTest("C4ZZA");
		execptionTest("C44ZZZZ");
	}

	protected static String read(File file) {
		Long filelength = file.length();
		byte[] filecontent = new byte[filelength.intValue()];
		InputStream in = null;
		try {
			in = new FileInputStream(file);
			in.read(filecontent);

		} catch (IOException e) {
			throw new Base32Exception("Error read file " + file.getName());
		} finally {
			if (in != null) {
				try {
					in.close();
				} catch (IOException e) {
				}
			}
		}
		return new String(filecontent);
	}

	protected static void write(File file, String content) {
		FileWriter fw = null;
		try {
			fw = new FileWriter(file);
			fw.write(content);
		} catch (IOException e) {
			throw new Base32Exception("Error write file " + file.getName());
		} finally {
			if (fw != null) {
				try {
					fw.close();
				} catch (IOException e) {
				}
			}
		}
	}

	protected static void execute(String[] args) {
		String option = args[0];
		String inFileName = args[1];
		String outFileName = args[2];

		File inFile = new File(inFileName);
		File outFile = new File(outFileName);
		if (!inFile.exists()) {
			throw new Base32Exception(inFileName + " does not exist");
		}
		if (!outFile.exists()) {
			throw new Base32Exception(outFileName + " does not exist");
		}

		String input = read(inFile);
		if ("-e".equals(option)) {
			String encoded = CustomizedBase32.getEncoder().encodeToString(input.getBytes());
			write(outFile, encoded);
		} else if ("-d".equals(option)) {
			String decoded = CustomizedBase32.getDecoder().decodeToString(input);
			write(outFile, decoded);
		}
	}

	public static void main(String[] args) {
		if (args != null && args.length >= 3) {
			execute(args);
		} else {
//			test2();
			String s = "CZEVBB2H";
			char[] a = s.toCharArray();
			for (int i = 0; i < a.length; i++){
				System.out.print(Integer.toBinaryString((int)a[i]));
			}
		}

	}

}
