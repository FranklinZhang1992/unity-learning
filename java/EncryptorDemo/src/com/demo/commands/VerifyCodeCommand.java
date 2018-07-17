package com.demo.commands;

import com.demo.exception.EncryptErrorException;

public class VerifyCodeCommand implements ICommand {

	private static final int MANDATORY_ARG_NUM = 3;

	@Override
	public void excute(String[] args, boolean verbose) {
		throw new EncryptErrorException("Not implemented yet");
	}

	@Override
	public int mandatoryArgNum() {
		return MANDATORY_ARG_NUM;
	}

}
