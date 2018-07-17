package com.demo.commands;

public interface ICommand {

	public void excute(String[] args, boolean verbose);

	public int mandatoryArgNum();
}
