import java.io.File;

public class Main {

	public static void main(String[] args) {
		File inputFile = new File("/home/franklin/download/ova/test.ova");
		File outputDir = new File("/home/franklin/download/ova/output");
		DecompressUtil.unTar(inputFile, outputDir);
		System.out.println("Done");
	}

}
