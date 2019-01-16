package com.demo;

/**
 * Class for storing a system command execution result, including the exit value
 * and the output of the command
 *
 */
public class ExecutionResult {

	private final int exitValue;
	private final String output;

	public ExecutionResult(int exitValue, String output) {
		this.exitValue = exitValue;
		this.output = output;
	}

	/**
	 * @return the exitValue
	 */
	public int getExitValue() {
		return exitValue;
	}

	/**
	 * @return the output
	 */
	public String getOutput() {
		return output;
	}

	/**
	 * @return the isSucceed
	 */
	public boolean isSucceed() {
		return exitValue == 0;
	}
}
