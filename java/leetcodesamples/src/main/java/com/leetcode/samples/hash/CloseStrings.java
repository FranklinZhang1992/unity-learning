package com.leetcode.samples.hash;

import com.leetcode.samples.utils.AssertUtils;

import java.util.Arrays;

/**
 * 1657. 确定两个字符串是否接近
 * <p>
 * 提示
 * 如果可以使用以下操作从一个字符串得到另一个字符串，则认为两个字符串 接近 ：
 * <p>
 * 操作 1：交换任意两个 现有 字符。
 * 例如，abcde -> aecdb
 * 操作 2：将一个 现有 字符的每次出现转换为另一个 现有 字符，并对另一个字符执行相同的操作。
 * 例如，aacabb -> bbcbaa（所有 a 转化为 b ，而所有的 b 转换为 a ）
 * 你可以根据需要对任意一个字符串多次使用这两种操作。
 * <p>
 * 给你两个字符串，word1 和 word2 。如果 word1 和 word2 接近 ，就返回 true ；否则，返回 false 。
 */
public class CloseStrings {

    /**
     * 逻辑简化，只要两个字符串长度一样，字母一样，各种字母的数量一样，即可转化成果
     *
     * @param word1
     * @param word2
     * @return
     */
    public boolean closeStrings(String word1, String word2) {
        // 长度不一致，直接返回false
        if (word1.length() != word2.length()) {
            return false;
        }
        int charNum = 26;
        // 统计每个字母出现的次数
        int[] count1 = new int[charNum];
        int[] count2 = new int[charNum];
        char[] word1Array = word1.toCharArray();
        char[] word2Array = word2.toCharArray();
        // 因为2个字符串长度一致，因此取任一字符串的长度进行遍历即可
        for (int i = 0; i < word1Array.length; i++) {
            count1[(int) word1Array[i] - 'a'] += 1;
            count2[(int) word2Array[i] - 'a'] += 1;
        }
        // 对统计好的数组依次判断，只要发现有数量不一致的，则返回false
        for (int i = 0; i < charNum; i++) {
            if ((count1[i] == 0) != (count2[i] == 0)) {
                return false;
            }
        }
        // 排序后依次判断各类型字母的数量是否一致，不一致则返回false
        Arrays.sort(count1);
        Arrays.sort(count2);
        for (int i = 0; i < charNum; i++) {
            if (count1[i] != count2[i]) {
                return false;
            }
        }

        return true;
    }

    public static void main(String[] args) {
        CloseStrings closeStrings = new CloseStrings();
        AssertUtils.isTrue(closeStrings.closeStrings("abc", "bca"));
        AssertUtils.isFalse(closeStrings.closeStrings("a", "aa"));
        AssertUtils.isTrue(closeStrings.closeStrings("cabbba", "abbccc"));
    }
}
