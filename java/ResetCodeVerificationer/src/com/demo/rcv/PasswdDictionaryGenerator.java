package com.demo.rcv;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Random;

public class PasswdDictionaryGenerator {

	public static void main(String[] args) {

		Random random = new Random();
		List<String> allCharList = new ArrayList<String>();
		// Set<Integer> chosenSet = new HashSet<Integer>();
		Map<String, String> map = new HashMap<String, String>();
		for (int i = 0; i < 10; i++) {
			allCharList.add(Integer.toString(i));
		}
		for (int i = 65; i < 65 + 26; i++) {
			allCharList.add(String.valueOf((char) i));
		}
		for (int i = 97; i < 97 + 26; i++) {
			allCharList.add(String.valueOf((char) i));
		}
		int i = 0;
		while (map.size() < allCharList.size()) {
			int index = random.nextInt(allCharList.size());
			// if (chosenSet.contains(index)) {
			// continue;
			// }
			map.put(allCharList.get(i), allCharList.get(index));
			i++;
		}

		for (Entry<String, String> entry : map.entrySet()) {
			System.out.println("put(\"" + entry.getKey() + "\", \"" + entry.getValue() + "\");");
		}

	}

}
