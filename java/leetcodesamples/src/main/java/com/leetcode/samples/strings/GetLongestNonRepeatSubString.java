package com.leetcode.samples.strings;

import com.leetcode.samples.utils.AssertUtils;

import java.util.HashSet;
import java.util.Set;

/**
 * 3. 给定一个字符串，请你找出其中不含有重复字符的
 */
public class GetLongestNonRepeatSubString {

    public int getMaxLen(String s) {
        char[] charArr = s.toCharArray();
        Set<Character> set = new HashSet<>();
        int i = 0;
        int j = 0;
        int maxLen = 0;
        while (i < charArr.length && j < charArr.length) {
            if (!set.contains(charArr[j])) {
                set.add(charArr[j]);
                maxLen = Math.max(maxLen, set.size());
                j++;
            } else {
                set.remove(charArr[j]);
                i++;
            }
        }
        return maxLen;
    }

    public static void main(String[] args) {
        GetLongestNonRepeatSubString getLongestNonRepeatSubString = new GetLongestNonRepeatSubString();
        AssertUtils.equals(3, getLongestNonRepeatSubString.getMaxLen("abcabcbb"));
    }
}
