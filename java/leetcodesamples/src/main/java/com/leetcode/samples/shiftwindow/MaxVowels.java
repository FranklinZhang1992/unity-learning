package com.leetcode.samples.shiftwindow;

import com.leetcode.samples.utils.AssertUtils;

import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * 1456. 定长子串中元音的最大数目
 * <p>
 * 提示
 * 给你字符串 s 和整数 k 。
 * <p>
 * 请返回字符串 s 中长度为 k 的单个子字符串中可能包含的最大元音字母数。
 * <p>
 * 英文中的 元音字母 为（a, e, i, o, u）。
 */
public class MaxVowels {

    private static final Set<Character> VOWEL_SET = Stream.of('a', 'e', 'i', 'o', 'u').collect(Collectors.toSet());

    public int maxVowels(String s, int k) {
        int sum = 0;
        int ans = 0;
        int i = 0;
        int j = 0;
        char[] array = s.toCharArray();
        while (j < array.length) {
            char newC = array[j];
            // 窗口未满
            if (j - i + 1 <= k) {
                // 窗口未满时，每新识别到一个元音，总数+1
                if (isVowel(newC)) {
                    sum++;
                }
                j++;
            } else {
                ans = Math.max(ans, sum);
                // 窗口满了，则需要进一个新的，出一个老的
                char oldC = array[i];
                // 若进了个元音，出了个非元音，则说明新窗口中的元音数更多，则maxNum可以+1
                if (isVowel(newC) && !isVowel(oldC)) {
                    sum++;
                }
                if (!isVowel(newC) && isVowel(oldC)) {
                    sum--;
                }

                // 窗口平移
                i++;
                j++;
            }
        }
        ans = Math.max(ans, sum);
        return ans;
    }

    private boolean isVowel(char c) {
        return VOWEL_SET.contains(c);
    }

    public static void main(String[] args) {
        MaxVowels maxVowels = new MaxVowels();
        AssertUtils.equals(3, maxVowels.maxVowels("abciiidef", 3));
        AssertUtils.equals(2, maxVowels.maxVowels("aeiou", 2));
        AssertUtils.equals(2, maxVowels.maxVowels("leetcode", 3));
    }
}
