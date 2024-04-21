package com.leetcode.samples.utils;

public final class AssertUtils {

    public static void isFalse(boolean result) {
        if (result) {
            throw new RuntimeException("AssertUtils::isTrue结果不为False");
        }
    }

    public static void isTrue(boolean result) {
        if (!result) {
            throw new RuntimeException("AssertUtils::isTrue结果不为True");
        }
    }

    public static void equals(Object expect, Object actual) {
        if (doEquals(expect, actual)) {
            return;
        }
        throw new RuntimeException("AssertUtils::equals比对结果为不相等，" + expect + "<>" + actual);
    }

    private static boolean doEquals(Object expect, Object actual) {
        if (expect == null) {
            return actual == null;
        }
        return expect.equals(actual);
    }
}
