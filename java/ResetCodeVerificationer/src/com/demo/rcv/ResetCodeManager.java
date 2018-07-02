package com.demo.rcv;

public class ResetCodeManager {

	private static final String encryptionKey = "ResetCodeManager";
	private static final ResetCodeManager instance = new ResetCodeManager();

	private ResetCodeManager() {
	}

	public static ResetCodeManager getInstance() {
		return instance;
	}

	public String generateValidationCode() {
		ValidationCodeTemplate vct = new ValidationCodeTemplate(ValidationCodeType.ADMIN_USER, encryptionKey);
		String vc = vct.getValidationCode();
		System.out.println("Get validation code: " + vc);
		String evc = vct.getEncryptedValidationCode();
		System.out.println("Get encrypted validation code: " + evc);
		return evc;
	}

	public String generateResetCodeByValidationCode() {
		return generateResetCodeByValidationCode(null);
	}

	public String generateResetCodeByValidationCode(String validationCode) {
		ResetCodeTemplate rct = new ResetCodeTemplate();
		rct.init(validationCode, encryptionKey);
		String rc = rct.getResetCode();
		System.out.println("Get reset code: " + rc);
		String erc = rct.getEncryptedResetCode();
		System.out.println("Get encrypted reset code: " + rc);
		return erc;
	}
}
