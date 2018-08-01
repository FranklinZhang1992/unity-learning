package com.demo.ow;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

public class Main {

	private static final String OBJ_FILE = "obj.obj";

	protected static void writeObj(Object obj) throws IOException {
		ObjectOutputStream oos = null;
		try {
			oos = new ObjectOutputStream(new FileOutputStream(OBJ_FILE));
			oos.writeObject(obj);
		} finally {
			if (oos != null) {
				oos.flush();
				oos.close();
			}
		}
	}

	protected static <T extends IUser> void readObj(Class<T> cls) throws ClassNotFoundException, IOException {
		ObjectInputStream ois = null;
		try {
			ois = new ObjectInputStream(new FileInputStream(OBJ_FILE));
			T obj = cls.cast(ois.readObject());
			System.out.println(obj.inspect());
		} finally {
			if (ois != null) {
				ois.close();
			}
		}
	}

	protected static void writeTest() throws IOException {
		User user = new User();
		user.setName("user");
		user.setAge(10);
		user.setActive(true);
		writeObj(user);
		System.out.println("WRITE DONE");
	}

	protected static void readTest() throws ClassNotFoundException, IOException {
		readObj(User.class);
		System.out.println("READ DONE");
	}

	public static void main(String[] args) throws IOException, ClassNotFoundException {
//		writeTest();
		readTest();

	}

}
