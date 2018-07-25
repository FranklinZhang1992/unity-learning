package com.demo.encoder;

import java.util.Base64;

public class Entanglor {

	private static final int USE_FIRST_N = 9;

	private String toBinaryStr(byte[] bytes) {
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < bytes.length; i++) {
			sb.append(fill0(Integer.toBinaryString(bytes[i])));
		}
		return sb.toString();
	}

	private byte[] toByteArray(String binStr) {
		int num = binStr.length() / 8;
		byte[] bytes = new byte[num];
		int j = 0;
		for (int i = 0; i < num; i++) {
			String tmp = binStr.substring(j, j + 8);
			bytes[i] = Integer.valueOf(tmp, 2).byteValue();
			j += 8;
		}
		return bytes;
	}

	private String fill0(String origStr) {
		char[] ret = new char[8];
		char[] origChar = origStr.toCharArray();
		int fillLen = 8 - origChar.length;

		for (int i = 0; i < fillLen; i++) {
			ret[i] = '0';
		}
		for (int i = fillLen; i < 8; i++) {
			int j = i - fillLen;
			ret[i] = origChar[j];
		}
		return String.valueOf(ret);
	}

	private byte[] subByteArray(byte[] bytes, int beginIndex, int length) {
		byte[] ret = new byte[length];
		int j = 0;
		for (int i = beginIndex; i < beginIndex + length; i++) {
			ret[j++] = bytes[i];
		}
		return ret;
	}

	private byte[] interweave(byte[] plaintext) {
		byte[] interweaved = new byte[plaintext.length];
		byte[] requestId = subByteArray(plaintext, 0, USE_FIRST_N);
		byte[] requestTime = subByteArray(plaintext, USE_FIRST_N, plaintext.length - USE_FIRST_N);

		char[] requestIdBins = toBinaryStr(requestId).toCharArray();
		char[] requestTimeBins = toBinaryStr(requestTime).toCharArray();

		int p0 = 0;
		int p1 = 0;
		int p2 = 0;
		char[] ret = new char[8 * 13];
		for (int i = 0; i < 8; i++) {
			for (int j = 0; j < 4; j++) {
				ret[p0++] = requestTimeBins[p1++];
			}
			for (int j = 0; j < 9; j++) {
				ret[p0++] = requestIdBins[p2++];
			}
		}
		String retStr = new String(ret);
		interweaved = toByteArray(retStr);
		return interweaved;

	}

	public void test(String systemUuid) {
		long epoch = System.currentTimeMillis();
		byte[] milliBytes = String.valueOf(epoch).getBytes();
		int milliBytesLen = milliBytes.length;
		byte[] timeChangingBytes = new byte[4];

		// Extract last 4 bytes in reverse order
		for (int i = 0; i < 4; i++) {
			timeChangingBytes[i] = milliBytes[milliBytesLen - i - 1];
		}

		byte[] plaintext = new byte[USE_FIRST_N + 4];

		char[] systemUuidChars = systemUuid.toCharArray();

		// Get first 9 bytes from system uuid
		int j = 0;
		for (int i = 0; i < systemUuidChars.length; i++) {
			if (j < USE_FIRST_N && systemUuidChars[i] != '-') {
				plaintext[j] = (byte) systemUuidChars[i];
				j++;
			}
		}

		for (int i = 0; i < 4; i++) {
			plaintext[i + USE_FIRST_N] = timeChangingBytes[i];
		}

		System.out.println("Raw code: " + new String(plaintext));
		System.out.println("After entangle(Base64): " + Base64.getEncoder().encodeToString(interweave(plaintext)));
		try {
			Thread.sleep(1);
		} catch (InterruptedException e) {
		}
	}

	public static void main(String[] args) {
		Entanglor entangle = new Entanglor();
		entangle.test("161a9d1c6b434e998e52e5be7356e438");
		entangle.test("161a9d1c6b434e998e52e5be7356e438");
		entangle.test("161a9d1c6b434e998e52e5be7356e438");
		entangle.test("161a9d1c6b434e998e52e5be7356e438");
		entangle.test("161a9d1c6b434e998e52e5be7356e438");
		entangle.test("161a9d1c6b434e998e52e5be7356e438");
		entangle.test("161a9d1c6b434e998e52e5be7356e438");
		entangle.test("161a9d1c6b434e998e52e5be7356e438");
		entangle.test("161a9d1c6b434e998e52e5be7356e438");
	}

}
