package com.leetcode.samples.reverseWords;

import java.util.LinkedList;
import java.util.List;
import java.util.StringJoiner;

/**
 * 151. 反转字符串中的单词
 * <p>
 * 给你一个字符串 s ，请你反转字符串中 单词 的顺序。
 * <p>
 * 单词 是由非空格字符组成的字符串。s 中使用至少一个空格将字符串中的 单词 分隔开。
 * <p>
 * 返回 单词 顺序颠倒且 单词 之间用单个空格连接的结果字符串。
 * <p>
 * 注意：输入字符串 s中可能会存在前导空格、尾随空格或者单词间的多个空格。返回的结果字符串中，单词间应当仅用单个空格分隔，且不包含任何额外的空格。
 */
public class ReverseWords {

    public String reverseWords(String s) {
        String[] arr = s.split(" ");
        List<String> wordList = new LinkedList<>();
        for (String string : arr) {
            push2List(wordList, string);
        }
        StringBuilder builder = new StringBuilder();
        for (int i = wordList.size() - 1; i >= 0; i--) {
            if ("".equals(builder.toString())) {
                builder.append(wordList.get(i));
            } else {
                builder.append(" ").append(wordList.get(i));
            }
        }
        return builder.toString();
    }

    private void push2List(List<String> wordList, String word) {
        if (word != null && word.matches("^[a-zA-Z0-9]+$")) {
            wordList.add(word);
        }
    }


}
