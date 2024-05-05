package com.leetcode.samples.dynamicprogramming;

import com.leetcode.samples.utils.AssertUtils;

/**
 * 72. 编辑距离
 * <p>
 * 给你两个单词 word1 和 word2， 请返回将 word1 转换成 word2 所使用的最少操作数  。
 * <p>
 * 你可以对一个单词进行如下三种操作：
 * <p>
 * 插入一个字符
 * 删除一个字符
 * 替换一个字符
 */
public class MinDistance {
    public int minDistance(String word1, String word2) {
        char[] word1Array = word1.toCharArray();
        char[] word2Array = word2.toCharArray();

        int[][] dp = new int[word1.length() + 1][word2.length() + 1];
        for (int i = 0; i <= word1.length(); i++) {
            dp[i][0] = i;
        }
        for (int i = 0; i < word2.length(); i++) {
            dp[0][i] = i;
        }

        for (int i = 1; i <= word1.length(); i++) {
            for (int j = 1; j <= word2.length(); j++) {
                if (word1Array[i - 1] == word2Array[j - 1]) {
                    dp[i][j] = dp[i - 1][j - 1];
                } else {
                    // word1 加1个字母
                    int n1 = dp[i - 1][j] + 1;
                    // word1 删1个字母
                    int n2 = dp[i][j - 1] + 1;
                    // word1替换1个字母
                    int n3 = dp[i - 1][j - 1] + 1;
                    dp[i][j] = Math.min(Math.min(n1, n2), n3);
                }
            }
        }
        return dp[word1.length()][word2.length()];
    }

    public static void main(String[] args) {
        MinDistance minDistance = new MinDistance();
        AssertUtils.equals(3, minDistance.minDistance("horse", "ros"));
        AssertUtils.equals(5, minDistance.minDistance("intention", "execution"));
    }
}
