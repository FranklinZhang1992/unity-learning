
public class Main {

	protected static void estimate(IEstimator estimator) {
		try {
			long startTime = System.currentTimeMillis();
			long size = estimator.estimatedExtractedFileSize();
			long endTime = System.currentTimeMillis();
			long interval = endTime - startTime;
			System.out
					.println("[" + estimator.getClass().getName() + "] Toal Size: " + size + " in " + interval + "ms");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static void main(String[] args) {
		String filePath = args[0];
		estimate(new TarEstimator(filePath));
		estimate(new GzipEstimator(filePath));
		estimate(new RandomAccessFileEstimator(filePath));
	}

}
