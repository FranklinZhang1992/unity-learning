package com.demo.rcv;

public class Main {

	private static ResetCodeManager manager = ResetCodeManager.getInstance();

	protected static void testEmailProcess() {
	}

	protected static void testSupportProcess() {
		String vc = manager.generateValidationCode();
		String rc1 = manager.generateResetCodeByValidationCode(vc);
		String rc2 = manager.generateResetCodeByValidationCode(vc);
		System.out.println("rc1 = " + rc1);
		System.out.println("rc2 = " + rc2);
		if (rc1.equals(rc2)) {
			System.out.println("reset code len = " + rc1.length());
			System.out.println("Verification succeed!");
		} else {
			System.out.println("Verification failed!");
		}
	}

	public static void main(String[] args) {
		testSupportProcess();
	}

}
