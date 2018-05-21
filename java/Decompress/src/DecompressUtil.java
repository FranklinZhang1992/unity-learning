import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import com.ice.tar.TarInputStream;

public class DecompressUtil {

	public static void unTar(final File inputFile, final File outputDir) {
		File outputFile = new File(outputDir, "output");

		TarInputStream tin = null;
		OutputStream out = null;
		try {
			tin = new TarInputStream(new FileInputStream(inputFile));
			out = new FileOutputStream(outputFile);

			byte[] buf = new byte[1024];
			int len;
			while ((len = tin.read(buf)) > 0) {
				out.write(buf, 0, len);
			}
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (out != null) {
				try {
					out.close();
				} catch (IOException e) {
				}
			}
			if (tin != null) {
				try {
					tin.close();
				} catch (IOException e) {
				}
			}
		}

	}
}
