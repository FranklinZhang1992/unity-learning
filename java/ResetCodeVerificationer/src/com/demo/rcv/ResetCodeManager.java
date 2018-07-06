package com.demo.rcv;

public class ResetCodeManager {

	private static final ResetCodeManager instance = new ResetCodeManager();

	private ResetCodeManager() {
	}

	public static ResetCodeManager getInstance() {
		return instance;
	}

	public String generateValidationCode() {
		ValidationCodeTemplate vct = new ValidationCodeTemplate(ValidationCodeType.ADMIN_USER);
		String vc = vct.getValidationCode();
		System.out.println("Get validation code: " + vc);
		return vc;
	}

	public String generateResetCodeByValidationCode() {
		return generateResetCodeByValidationCode(null);
	}

	public String generateResetCodeByValidationCode(String validationCode) {
		ResetCodeTemplate rct = new ResetCodeTemplate();
		rct.init(validationCode);
		String rc = rct.getResetCode();
		System.out.println("Get reset code: " + rc);
		return rc;
	}
}
