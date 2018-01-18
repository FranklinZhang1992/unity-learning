import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class WaitForTest {

	private static void printInputStreamAsync(final InputStream is) {
		new Thread(new Runnable() {
			public void run() {
				BufferedReader bf = new BufferedReader(new InputStreamReader(is));
				String line = null;
				try {
					while ((line = bf.readLine()) != null) {
						System.out.println(new String(line.getBytes("utf-8"), "utf-8"));
					}
				} catch (IOException e) {
					System.err.println("IOException in printInputStream" + e);
				} finally {
					if (bf != null) {
						try {
							bf.close();
						} catch (IOException e) {
						}
					}
				}
			}
		}).start();
	}

	private static void printInputStreamSync(final InputStream is) {
		BufferedReader bf = new BufferedReader(new InputStreamReader(is));
		String line = null;
		try {
			while ((line = bf.readLine()) != null) {
				System.out.println(new String(line.getBytes("utf-8"), "utf-8"));
			}
		} catch (IOException e) {
			System.err.println("IOException in printInputStream" + e);
		} finally {
			if (bf != null) {
				try {
					bf.close();
				} catch (IOException e) {
				}
			}
		}
	}

	private static void execTest(String command, boolean isSync) {
		System.out.println("================ exec command test begin");
		try {
			Process p = Runtime.getRuntime().exec(command);
			System.out.println("cmd thread start");
			if (isSync) {
				printInputStreamSync(p.getInputStream());
			} else {
				printInputStreamAsync(p.getInputStream());
			}
			System.out.println("waitFor");
			p.waitFor();
			System.out.println("waitFor end");
		} catch (IOException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		System.out.println("================ exec command test begin");
	}

	public static void main(String[] args) {
		String scriptLocation = System.getProperty("user.dir") + "/scripts/test.sh";
		execTest(scriptLocation, false);
	}

}
