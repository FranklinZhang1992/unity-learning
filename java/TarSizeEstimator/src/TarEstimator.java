import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

import com.ice.tar.TarInputStream;

public class TarEstimator implements IEstimator {

	private File tarFile;

	public TarEstimator(String path) {
		File file = new File(path);
		if (!file.exists()) {
			throw new RuntimeException("file not exist");
		}
		this.tarFile = file;
	}

	@Override
	public long estimatedExtractedFileSize() {
		long totalSize = 0L;
		TarInputStream tin = null;
		try {
			tin = new TarInputStream(new FileInputStream(this.tarFile));
			while (tin.available() > 0) {
				byte[] buf = new byte[1024];
				int read = tin.read(buf);
				if (read > 0)
					totalSize += read;
			}
			return totalSize;
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (tin != null) {
				try {
					tin.close();
				} catch (IOException e) {
				}
			}
		}
		return 0;
	}

}
