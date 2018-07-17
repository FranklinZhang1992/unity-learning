package com.demo.aes;

import java.util.Base64;
import java.util.Calendar;

public class TimeTest {

    private static void printTime(String prefix, Calendar cal) {
        int year = cal.get(Calendar.YEAR);
        int month = cal.get(Calendar.MONTH) + 1;
        int day = cal.get(Calendar.DAY_OF_MONTH);
        int hour = cal.get(Calendar.HOUR_OF_DAY);
        int minute = cal.get(Calendar.MINUTE);
        System.out.println(prefix + ": " + year + "-" + month + "-" + day + " " + hour + ":" + minute);
    }

    protected static void log(String msg, boolean verbose) {
        if (verbose) {
            System.out.println(msg);
        }
    }

    protected static void test(long orig, long current) {
        test(orig, current, false);
    }

    private static void test(long orig, long current, boolean verbose) {
        Calendar cal = Calendar.getInstance();
        // long orig = System.currentTimeMillis();
        // long orig = 1531705645585L;
        cal.setTimeInMillis(orig);
        // cal.add(Calendar.HOUR_OF_DAY, diff);
        printTime("Orig", cal);
        long l1 = orig & 0xffffffffff000000L;
        long l2 = orig & 0x0000000000ffffffL;
        log("l1 = " + l1 + ", l2 = " + l2, verbose);
        byte[] bytes = new byte[3];
        bytes[0] = (byte) (l2 >>> 16);
        bytes[1] = (byte) (l2 >>> 8);
        bytes[2] = (byte) l2;
        String encoded = Base64.getEncoder().encodeToString(bytes);
        log(encoded, verbose);
        byte[] decoded = Base64.getDecoder().decode(encoded);
        // long current = System.currentTimeMillis();
        // long current = 1531722422800L;
        long r1 = current & 0xffffffffff000000L;
        long r2 = ((decoded[0] << 16) & 0x0000000000ff0000L) | ((decoded[1] << 8) & 0x000000000000ff00L)
                | (decoded[2] & 0x000000000000000ffL);
        log("r1 = " + r1 + ",r2 = " + r2, verbose);
        long now = r1 + r2;
        cal.setTimeInMillis(now);
        printTime("Now", cal);
    }

    protected static void test2(long orig, long current) {
        test2(orig, current, false);
    }

    protected static void test2(long orig, long current, boolean verbose) {
        Calendar cal = Calendar.getInstance();
        cal.setTimeInMillis(orig);
        printTime("Orig", cal);
        long l1 = orig & 0xffffffff00000000L;
        long l2 = orig & 0x00000000ffffffffL;
        log("l1 = " + l1 + ", l2 = " + l2, verbose);
        char[] chars = new char[4];
        chars[0] = (char) (l2 >>> 24);
        chars[1] = (char) (l2 >>> 16);
        chars[2] = (char) (l2 >>> 8);
        chars[3] = (char) l2;
        String encoded = new String(chars);
        log(encoded, verbose);
        System.out.println("len = " + encoded.length());
        char[] decoded = encoded.toCharArray();
        long r1 = current & 0xffffffff00000000L;
        long r2 = ((decoded[0] << 24) & 0x00000000ff000000L) | ((decoded[1] << 16) & 0x0000000000ff0000L)
                | ((decoded[2] << 8) & 0x000000000000ff00L) | (decoded[3] & 0x000000000000000ffL);
        log("r1 = " + r1 + ", r2 = " + r2, verbose);
        long now = r1 + r2;
        cal.setTimeInMillis(now);
        printTime("Now", cal);
    }

    protected static void test3(long orig, long current, boolean verbose) {
        Calendar cal = Calendar.getInstance();
        cal.setTimeInMillis(orig);
        printTime("Orig", cal);
        long l = orig;
        char[] chars = new char[8];
        chars[0] = (char) ((l >>> 56) & 0xff);
        chars[1] = (char) ((l >>> 48) & 0xff);
        chars[2] = (char) ((l >>> 40) & 0xff);
        chars[3] = (char) ((l >>> 32) & 0xff);
        chars[4] = (char) ((l >>> 24) & 0xff);
        chars[5] = (char) ((l >>> 16) & 0xff);
        chars[6] = (char) ((l >>> 8) & 0xff);
        chars[7] = (char) (l & 0xff);
        String s = new String(chars);
        System.out.println("len = " + s.length());
        String encoded = Base64.getUrlEncoder().encodeToString(s.getBytes());
        log(encoded, verbose);
        System.out.println("len = " + encoded.length());
        byte[] decoded0 = Base64.getUrlDecoder().decode(encoded);
        char[] decoded = new String(decoded0).toCharArray();
        // long r = ((decoded[0] << 56) & 0xff00000000000000L) | ((decoded[1] <<
        // 48) & 0x00ff000000000000L)
        // | ((decoded[2] << 40) & 0x0000ff0000000000L) | ((decoded[3] << 32) &
        // 0x000000ff00000000L)
        // | ((decoded[4] << 24) & 0x00000000ff000000L) | ((decoded[5] << 16) &
        // 0x0000000000ff0000L)
        // | ((decoded[6] << 8) & 0x000000000000ff00L) | (decoded[7] &
        // 0x000000000000000ffL);
        long r = ((chars[0] << 56) & 0xff00000000000000L) | ((chars[1] << 48) & 0x00ff000000000000L)
                | ((chars[2] << 40) & 0x0000ff0000000000L) | ((chars[3] << 32) & 0x000000ff00000000L)
                | ((chars[4] << 24) & 0x00000000ff000000L) | ((chars[5] << 16) & 0x0000000000ff0000L)
                | ((chars[6] << 8) & 0x000000000000ff00L) | (chars[7] & 0x000000000000000ffL);
        long now = r;
        cal.setTimeInMillis(now);
        printTime("Now", cal);
    }

    public static void main(String[] args) {
        // test(1531709489152L, 1531726266367L, true);
        // test2(1527431299071L, 1531726266367L, true);
        // test3(1527431299071L, 1531726266367L, true);

        // Calendar cal = Calendar.getInstance();
        // cal.setTimeInMillis(1099511627775L);
        // printTime("Output", cal);

        char c = 126;
        System.out.println(c);

        // String o = "123456789012345";
        // System.out.println("Original len = " + o.length());
        // String base64Encoded =
        // Base64.getEncoder().encodeToString(o.getBytes());
        // System.out.println(base64Encoded);
        // System.out.println("Base64 Encode len = " + base64Encoded.length());
        // String base32Encoded =
        // CustomizedBase32.getEncoder().encodeToString(o.getBytes());
        // System.out.println(base32Encoded);
        // System.out.println("Base32 Encode len = " + base32Encoded.length());
    }

}
