package com.demo.base32;

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

	public static void main(String[] args) {
		test1();
	}

}
