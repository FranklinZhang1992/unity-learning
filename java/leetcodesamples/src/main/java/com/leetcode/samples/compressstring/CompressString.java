package com.leetcode.samples.compressstring;

import com.leetcode.samples.utils.AssertUtils;

/**
 * 443. 压缩字符串
 *
 * 给你一个字符数组 chars ，请使用下述算法压缩：
 *
 * 从一个空字符串 s 开始。对于 chars 中的每组 连续重复字符 ：
 *
 * 如果这一组长度为 1 ，则将字符追加到 s 中。
 * 否则，需要向 s 追加字符，后跟这一组的长度。
 * 压缩后得到的字符串 s 不应该直接返回 ，需要转储到字符数组 chars 中。需要注意的是，如果组长度为 10 或 10 以上，则在 chars 数组中会被拆分为多个字符。
 *
 * 请在 修改完输入数组后 ，返回该数组的新长度。
 *
 * 你必须设计并实现一个只使用常量额外空间的算法来解决此问题。
 */
public class CompressString {
    public int compress(char[] chars) {
        if (chars.length == 1) {
            return 1;
        }
        int write = 0;
        int read = 1;
        int ptr = 0;
        while (read < chars.length) {
            if (chars[ptr] != chars[read]) {
                int cnt = read - ptr;
                int ret = toCharArray(chars, write, cnt);
                write = write + ret + 1;
                chars[write] = chars[read];
                ptr = read;
            }
            read++;
        }
        int cnt = read - ptr;
        int ret = toCharArray(chars, write, cnt);

        return write + ret + 1;
    }

    private int toCharArray(char[] chars, int begin, int cnt) {
        if (cnt == 1) {
            return 0;
        }
        char[] cntCharArray = String.valueOf(cnt).toCharArray();
        for (int i = 0; i < cntCharArray.length; i++) {
            chars[begin + 1 + i] = cntCharArray[i];
        }
        return cntCharArray.length;
    }

    public static void main(String[] args) {
        CompressString compressString = new CompressString();
        char[] chars = new char[]{'a', 'a', 'b', 'b', 'c', 'c', 'c'};
        AssertUtils.equals(6, compressString.compress(chars));
        System.out.println("-----");
        chars = new char[]{'a'};
        AssertUtils.equals(1, compressString.compress(chars));
        System.out.println("-----");
        chars = new char[]{'a', 'b', 'b', 'b', 'b', 'b', 'b', 'b', 'b', 'b', 'b', 'b', 'b'};
        AssertUtils.equals(4, compressString.compress(chars));
        System.out.println("-----");
        chars = new char[]{'a', 'a', 'a', 'b', 'b', 'a', 'a'};
        AssertUtils.equals(6, compressString.compress(chars));
    }
}
