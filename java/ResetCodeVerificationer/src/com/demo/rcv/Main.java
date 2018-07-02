package com.demo.rcv;

public class Main {

	private static ResetCodeManager manager = ResetCodeManager.getInstance();

	protected static void testEmailProcess() {
	}

	protected static void testSupportProcess() {
		String vc = manager.generateValidationCode();
		String rc1 = manager.generateResetCodeByValidationCode(vc);
		String rc2 = manager.generateResetCodeByValidationCode(vc);
		if (rc1.equals(rc2)) {
			System.out.println("Verification succeed!");
		} else {
			System.out.println("Verification failed!");
		}
	}

	public static void main(String[] args) {
		testSupportProcess();
	}

}
