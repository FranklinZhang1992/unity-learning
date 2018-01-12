import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

public class Main {

    private static void printInputStream(final InputStream is) {
        new Thread(new Runnable() {
            public void run() {
                BufferedReader bf = new BufferedReader(new InputStreamReader(is));
                String line = null;
                try {
                    while ((line = bf.readLine()) != null) {
                        System.out.println(new String(line.getBytes("utf-8"), "utf-8"));
                    }
                }
                catch (IOException e) {
                    System.err.println("IOException in printInputStream" + e);
                }
            }
        }).start();
    }

    public static void main(String[] args) {
        String workingDir = "/tmp/test";
        File workingDirFile = new File(workingDir);
        List<String> cmdArray = Arrays.asList("virt-v2v", "-i", "ova", "/mnt/export/win10_pro", "-v", "-x", "-o", "mocktarget", "-of", "raw", "-os",
                "default");
        ProcessBuilder pb = new ProcessBuilder(cmdArray);
        pb.redirectErrorStream(true);
        pb.directory(workingDirFile);
        Map<String, String> env = pb.environment();
        env.put("LIBGUESTFS_CACHEDIR", "/tmp/test");
        InputStream is = null;
        System.out.println("Command exection start");
        try {
            Process p = pb.start();
            printInputStream(p.getInputStream());
            printInputStream(p.getErrorStream());
            p.waitFor();
            if (p.exitValue() == 0) {
                System.out.println("Command execution succeed");
            }
            else {
                System.err.println("Command execution failed");
            }
        }
        catch (IOException e) {
            System.err.println("IOException in exec cmd" + e);
        }
        catch (InterruptedException e) {
            System.err.println("InterruptedException in exec cmd" + e);
        }
        finally {
            if (is != null) {
                try {
                    is.close();
                }
                catch (IOException e) {
                }
            }
        }
    }
}
