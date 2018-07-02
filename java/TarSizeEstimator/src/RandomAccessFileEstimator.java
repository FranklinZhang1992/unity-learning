import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.RandomAccessFile;

public class RandomAccessFileEstimator implements IEstimator {
	private File tarFile;

	public RandomAccessFileEstimator(String path) {
		File file = new File(path);
		if (!file.exists()) {
			throw new RuntimeException("file not exist");
		}
		this.tarFile = file;
	}

	@Override
	public long estimatedExtractedFileSize() {
		long totalSize = 0L;
		RandomAccessFile raf = null;
		try {
			raf = new RandomAccessFile(this.tarFile, "r");
			raf.seek(raf.length() - 4);

			int b4 = raf.read();
			int b3 = raf.read();
			int b2 = raf.read();
			int b1 = raf.read();
			totalSize = (b1 << 24) | (b2 << 16) + (b3 << 8) + b4;

			return totalSize;
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (raf != null) {
				try {
					raf.close();
				} catch (IOException e) {
				}
			}
		}
		return 0;
	}
}
