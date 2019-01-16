package com.demo;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.ProcessBuilder.Redirect;
import java.util.List;
import java.util.Map;

/**
 * Util class for executing system command
 *
 */
public class SystemCommand {

	/**
	 * Execute a system command
	 * 
	 * @param command
	 *            The system command string list
	 * @return The execution result
	 */
	public static ExecutionResult execute(List<String> command) {
		return execute(command, null, null);
	}

	/**
	 * Execute a system command
	 * 
	 * @param command
	 *            The system command string list
	 * @param directory
	 *            Under which directory should the command be executed
	 * @param env
	 *            Command execution environment
	 * @return The execution result
	 */
	public static ExecutionResult execute(List<String> command, File directory, Map<String, String> env) {
		ProcessBuilder pb = new ProcessBuilder(command);
		pb.redirectErrorStream(true);
		if (directory != null) {
			pb.directory(directory);
		}
		if (env != null) {
			pb.environment().putAll(env);
		}
		Redirect redirect = pb.redirectInput();
		redirect.

		/* Start execution */
		try {
			Process p = pb.start();
			String output = getOutput(p.getInputStream());
			p.waitFor();
			return new ExecutionResult(p.exitValue(), output);
		} catch (IOException e) {
			return new ExecutionResult(-1, e.getMessage());
		} catch (InterruptedException e) {
			return new ExecutionResult(-1, e.getMessage());
		}
	}

	/**
	 * Get command output content from InputStream
	 * 
	 * @param is
	 *            InputStream get from
	 * @return The output content
	 * @throws IOException
	 */
	private static String getOutput(InputStream is) throws IOException {
		BufferedReader br = null;
		String line = null;
		StringBuilder sb = new StringBuilder();

		try {
			br = new BufferedReader(new InputStreamReader(is));
			while ((line = br.readLine()) != null) {
				sb.append(line + "\n");
			}
			return sb.toString();
		} finally {
			if (br != null) {
				try {
					br.close();
				} catch (IOException e) {
				}
			}
		}
	}
}
