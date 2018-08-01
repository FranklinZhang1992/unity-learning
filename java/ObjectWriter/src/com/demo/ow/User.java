package com.demo.ow;

public class User implements IUser {

	private static final long serialVersionUID = 1254989248699378938L;

	private String name;
	private int age;
	private boolean active;
	private long n;

	/**
	 * @return the name
	 */
	public String getName() {
		return name;
	}

	/**
	 * @param name
	 *            the name to set
	 */
	public void setName(String name) {
		this.name = name;
	}

	/**
	 * @return the age
	 */
	public int getAge() {
		return age;
	}

	/**
	 * @param age
	 *            the age to set
	 */
	public void setAge(int age) {
		this.age = age;
	}

	/**
	 * @return the active
	 */
	public boolean isActive() {
		return active;
	}

	/**
	 * @param active
	 *            the active to set
	 */
	public void setActive(boolean active) {
		this.active = active;
	}

	@Override
	public String inspect() {
		StringBuilder sb = new StringBuilder();
		sb.append("name: " + this.name + "\n");
		sb.append("age: " + this.age + "\n");
		sb.append("active: " + this.active + "\n");
		sb.append("n: " + this.n + "\n");
		return sb.toString();
	}

	/**
	 * @return the n
	 */
	public long getN() {
		return n;
	}

	/**
	 * @param n
	 *            the n to set
	 */
	public void setN(long n) {
		this.n = n;
	}

}
