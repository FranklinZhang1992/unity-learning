package com.leetcode.samples.stringmerge;

/**
 * 交替合并字符串
 * 给你两个字符串 word1 和 word2 。请你从 word1 开始，通过交替添加字母来合并字符串。如果一个字符串比另一个字符串长，就将多出来的字母追加到合并后字符串的末尾。
 * <p>
 * 返回 合并后的字符串 。
 */
public class MergeStringInTurn {

    public String mergeAlternately(String word1, String word2) {
        if (word1 == null && word2 == null) {
            return "";
        }
        if (word1 == null) {
            return word2;
        }
        if (word2 == null) {
            return word1;
        }
        char[] word1Array = word1.toCharArray();
        char[] word2Array = word2.toCharArray();
        StringBuilder builder = new StringBuilder();
        int i = 0;
        int j = 0;
        while (builder.length() < word1.length() + word2.length()) {
            if (i < word1.length()) {
                builder.append(word1Array[i++]);
            }
            if (j < word2.length()) {
                builder.append(word2Array[j++]);
            }
        }
        return builder.toString();
    }


}

