import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.zip.GZIPInputStream;

public class GzipEstimator implements IEstimator {

	private File tarFile;

	public GzipEstimator(String path) {
		File file = new File(path);
		if (!file.exists()) {
			throw new RuntimeException("file not exist");
		}
		this.tarFile = file;
	}

	@Override
	public long estimatedExtractedFileSize() {
		long totalSize = 0L;
		GZIPInputStream gin = null;
		try {
			gin = new GZIPInputStream(new FileInputStream(this.tarFile));
			while (gin.available() > 0) {
				byte[] buf = new byte[1024];
				int read = gin.read(buf);
				if (read > 0)
					totalSize += read;
			}
			return totalSize;
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (gin != null) {
				try {
					gin.close();
				} catch (IOException e) {
				}
			}
		}
		return 0;
	}
}
