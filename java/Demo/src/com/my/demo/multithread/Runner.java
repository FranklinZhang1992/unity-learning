package com.my.demo.multithread;

public class Runner implements Runnable {

	private Thread thread;

	  public synchronized void start() {
		  if (thread != null) {
			  System.out.println("starting, state = " + Thread.currentThread().getState().name());
		  }
	        if (thread == null) {
	            thread = new Thread(this);
	            thread.start();
	        }
	        else if (thread.isInterrupted()) {
	            thread.start();
	        }
	    }
	  
	@Override
	public void run() {
		System.out.println("running-start");
		System.out.println("is alive: " + thread.isAlive());
		System.out.println("is int: " + thread.isInterrupted());
		System.out.println("running-end");
	}
	
	public synchronized void stop() {
		System.out.println("stopping-start");
		System.out.println("before: is alive: " + thread.isAlive());
		System.out.println("before: is int: " + thread.isInterrupted());
		thread.interrupt();
		System.out.println("after: is alive: " + thread.isAlive());
		System.out.println("after: is int: " + thread.isInterrupted());
		System.out.println("stopping-end");
}


}
