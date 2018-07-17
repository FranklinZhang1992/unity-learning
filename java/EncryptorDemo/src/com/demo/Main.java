package com.demo;

import com.demo.commands.CommandLine;
import com.demo.exception.EncryptErrorException;

public class Main {

	public static void main(String[] args) throws InterruptedException {
		try {
			CommandLine cmd = new CommandLine(args);
			for (int i = 0; i < cmd.getExecCount(); i++) {
				cmd.execute();
				Thread.sleep(1);
			}
		} catch (EncryptErrorException e) {
			System.out.println(e.getMessage());
		}
	}

}
