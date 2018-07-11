import java.util.Base64;

public class Main {

	private static final char[] toBase32 = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D',
			'E', 'F', 'G', 'H', 'J', 'K', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y' };
	protected static int base64OutLength(String src) {
		return 4 * ((src.getBytes().length + 2) / 3);
	}

	protected static int base32OutLength(String src) {
		return 8 * ((src.getBytes().length + 4) / 5);
	}

	public static void main(String[] args) {
		// Base64.getEncoder().encodeToString("".getBytes());
		// System.out.println("a".getBytes().length);
		// System.out.println("ab".getBytes().length);
		// System.out.println("abc".getBytes().length);

		// System.out.println(Base64.getEncoder().encodeToString("a".getBytes()));
		// System.out.println(Base64.getEncoder().encodeToString("ab".getBytes()));
		// System.out.println(Base64.getEncoder().encodeToString("abc".getBytes()));
		// System.out.println(Base64.getEncoder().encodeToString("abcd".getBytes()));
		// System.out.println(Base64.getEncoder().encodeToString("abcde".getBytes()));
		// System.out.println(Base64.getEncoder().encodeToString("abcdef".getBytes()));

		// System.out.println(base64OutLength("a"));
		// System.out.println(base64OutLength("ab"));
		// System.out.println(base64OutLength("abc"));
		// System.out.println(base64OutLength("abcd"));
		// System.out.println(base64OutLength("abcde"));
		// System.out.println(base64OutLength("abcdef"));

//		System.out.println(base32OutLength("a"));
//		System.out.println(base32OutLength("ab"));
//		System.out.println(base32OutLength("abc"));
//		System.out.println(base32OutLength("abcd"));
//		System.out.println(base32OutLength("abcde"));
//		System.out.println(base32OutLength("abcdef"));

		// System.out.println(CustomizedBase32.getEncoder().encode("abc".getBytes()));
		
		System.out.println(toBase32['C']);
	}

}
