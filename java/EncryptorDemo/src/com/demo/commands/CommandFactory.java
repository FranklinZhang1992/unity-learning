package com.demo.commands;

import java.util.HashMap;
import java.util.Map;

public class CommandFactory {

	private static Map<String, ICommand> commands = new HashMap<String, ICommand>();

	static {
		commands.put("request-code", new GenRequestCodeCommand());
		commands.put("response-code", new GenResponseCodeCommand());
		commands.put("verify", new VerifyCodeCommand());
	}

	public static ICommand getCommand(String commandName) {
		return commands.get(commandName);
	}
}
