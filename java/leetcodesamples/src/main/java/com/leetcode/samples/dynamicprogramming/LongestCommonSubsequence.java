package com.leetcode.samples.dynamicprogramming;

import com.leetcode.samples.utils.AssertUtils;

/**
 * 1143. 最长公共子序列
 * <p>
 * 提示
 * 给定两个字符串 text1 和 text2，返回这两个字符串的最长 公共子序列 的长度。如果不存在 公共子序列 ，返回 0 。
 * <p>
 * 一个字符串的 子序列 是指这样一个新的字符串：它是由原字符串在不改变字符的相对顺序的情况下删除某些字符（也可以不删除任何字符）后组成的新字符串。
 * <p>
 * 例如，"ace" 是 "abcde" 的子序列，但 "aec" 不是 "abcde" 的子序列。
 * 两个字符串的 公共子序列 是这两个字符串所共同拥有的子序列。
 */
public class LongestCommonSubsequence {

    public int longestCommonSubsequence(String text1, String text2) {
        char[] text1CharArr = text1.toCharArray();
        char[] text2CharArr = text2.toCharArray();
        int[][] dp = new int[text1CharArr.length + 1][text2CharArr.length + 1];
        for (int i = 1; i <= text1CharArr.length; i++) {
            for (int j = 1; j <= text2CharArr.length; j++) {
                if (text1CharArr[i - 1] == text2CharArr[j - 1]) {
                    dp[i][j] = dp[i - 1][j - 1] + 1;
                } else {
                    dp[i][j] = Math.max(dp[i - 1][j], dp[i][j - 1]);
                }
            }
        }
        return dp[text1CharArr.length][text2CharArr.length];
    }

    public static void main(String[] args) {
        LongestCommonSubsequence longestCommonSubsequence = new LongestCommonSubsequence();
        AssertUtils.equals(3, longestCommonSubsequence.longestCommonSubsequence("abcde", "ace"));
    }
}