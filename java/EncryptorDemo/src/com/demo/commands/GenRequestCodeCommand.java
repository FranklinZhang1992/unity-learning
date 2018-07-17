package com.demo.commands;

import java.util.ArrayList;
import java.util.List;

import com.demo.exception.EncryptErrorException;
import com.demo.util.Base32;

public class GenRequestCodeCommand implements ICommand {

	private boolean verbose;

	private static final int USE_FIRST_N = 9;
	private static final int MANDATORY_ARG_NUM = 1;
	private static final char[] salt1 = "salt11".toCharArray();
	private static final char[] salt2 = "salt222".toCharArray();
	private static final char[] secret = "ABC".toCharArray();

	@Override
	public void excute(String[] args, boolean verbose) {
		if (args.length < MANDATORY_ARG_NUM) {
			throw new EncryptErrorException("Argument <system_uuid> is required");
		}
		this.verbose = verbose;
		String system_uuid = args[0];
		if (this.verbose)
			System.out.println("System UUID: " + system_uuid);

		long epoch = System.currentTimeMillis();
		if (this.verbose)
			System.out.println("Millisecs since 1/1/1970: " + epoch);

		byte[] milliBytes = String.valueOf(epoch).getBytes();
		int milliBytesLen = milliBytes.length;
		byte[] timeChangingBytes = new byte[4];

		// Extract last 4 bytes in reverse order
		for (int i = 0; i < 4; i++) {
			timeChangingBytes[i] = milliBytes[milliBytesLen - i - 1];
		}
		if (this.verbose)
			System.out.println("Milli Bytes: " + new String(timeChangingBytes));

		byte[] plaintext = new byte[USE_FIRST_N + 4];

		char[] systemUuidChars = system_uuid.toCharArray();

		// Get first 9 bytes from system uuid
		if (this.verbose)
			System.out.println("System UUID bytes: ");
		int j = 0;
		for (int i = 0; i < systemUuidChars.length; i++) {
			if (j < USE_FIRST_N && systemUuidChars[i] != '-') {
				plaintext[j] = (byte) systemUuidChars[i];
				if (this.verbose)
					System.out.print(systemUuidChars[i]);
				j++;
			}
		}
		if (this.verbose)
			System.out.println();
		for (int i = 0; i < 4; i++) {
			plaintext[i + USE_FIRST_N] = timeChangingBytes[i];
		}

		if (this.verbose)
			System.out.println("plaintext: " + new String(plaintext));

		// interweave time bits with UUID bits
		byte[] interweaved = interweave(plaintext);

		// Encrypt with Home-Brew algo
		encryptMemoryBasic(interweaved, interweaved.length);

		// 5-bit encode
		String encoded = Base32.getEncoder().encodeToString(interweaved);

		if (this.verbose)
			System.out.println("After encrypt & 5-bit encode: " + encoded);

		// Format code
		String formattedCode = formatCode(encoded);

		System.out.println("Request code: " + formattedCode);
		if (this.verbose)
			System.out.println("Code length: " + formattedCode.length());
	}

	private String formatCode(String orig) {
		List<String> codeSlices = new ArrayList<String>();
		int sliceLen = 5;
		int j = 0;
		for (int i = 0; i < orig.length() / sliceLen; i++) {
			codeSlices.add(orig.substring(j, j + sliceLen));
			j += sliceLen;
		}
		if (j < orig.length()) {
			codeSlices.add(orig.substring(j));
		}
		return String.join("-", codeSlices);
	}

	private byte[] interweave(byte[] plaintext) {
		if (this.verbose)
			System.out.println("Interweaving time bits with the UUID bits...");
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

	private void encryptMemoryBasic(byte[] ebuffer, int n_bytes) {
		// First Encrypt Step: salt the data to be encrypted
		for (int i = 0; i < n_bytes; i++)
			ebuffer[i] = (byte) (ebuffer[i] ^ salt1[i % salt1.length]);
		// Second Encrypt Step: encrypt data with secret
		for (int i = 0; i < n_bytes; i++)
			ebuffer[i] = (byte) (ebuffer[i] ^ secret[i % secret.length]);
		// Third Encrypt Step: add second layer of salt
		for (int i = 0; i < n_bytes; i++)
			ebuffer[i] = (byte) (ebuffer[i] ^ salt2[i % salt2.length]);
	}

	@Override
	public int mandatoryArgNum() {
		return MANDATORY_ARG_NUM;
	}

}
