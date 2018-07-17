package com.demo.commands;

import com.demo.exception.EncryptErrorException;

public class CommandLine {

	private static final int DEFAULT_EXEC_COUNT = 1;
	private ICommand command;
	private String[] args;
	private boolean verbose = false;
	private int execCount = 0;

	private boolean isVerbose() {
		// Do not enter verbose mode if EXEC_COUNT is bigger than 1,
		// otherwise you will be disturbed
		return execCount <= 1;
	}

	private void showHelp() {
		StringBuilder sb = new StringBuilder();
		sb.append("Usage: COMMAND <arg1> <arg2> [execute_count] ...\n\n");
		sb.append("\trequest-code <system_uuid>                                Generate request code\n");
		sb.append("\tresponse-code <request_code> <system_uuid>                Generate response code\n");
		sb.append("\tverify <request_code> <response_code> <system_uuid>       Verify response code\n");
		System.out.println(sb.toString());
	}

	public CommandLine(String[] args) {
		if (args == null || args.length < 1) {
			throw new EncryptErrorException("Sub-command (request-code | response-code | verify) is required!");
		} else if ("help".equals(args[0]) || "-h".equals(args[0]) || "--help".equals(args[0])) {
			showHelp();
			return;
		}

		command = CommandFactory.getCommand(args[0]);
		if (command == null) {
			throw new EncryptErrorException("No such command: " + args[0]);
		}

		int neededArgsCount = 1 + command.mandatoryArgNum();
		if (args.length < neededArgsCount) {
			throw new EncryptErrorException(
					"Not enough arguments, " + neededArgsCount + " required but only " + args.length + " specified");
		}

		this.execCount = DEFAULT_EXEC_COUNT;
		// If exec count is specified, then pick that
		// 1 sub-command + multi command args + 1 exec count
		if (args.length > neededArgsCount) {
			this.execCount = Integer.valueOf(args[args.length - 1]);
		}

		this.args = new String[args.length - 1];
		for (int i = 0; i < command.mandatoryArgNum(); i++) {
			this.args[i] = args[i + 1];
		}

		this.verbose = isVerbose();
	}

	public void execute() {
		command.excute(args, verbose);
	}

	/**
	 * @return the execCount
	 */
	public int getExecCount() {
		return execCount;
	}

}
