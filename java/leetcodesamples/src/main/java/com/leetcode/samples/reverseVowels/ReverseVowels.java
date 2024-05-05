package com.leetcode.samples.reverseVowels;

import com.leetcode.samples.utils.AssertUtils;

import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * 345. 反转字符串中的元音字母
 * <p>
 * 给你一个字符串 s ，仅反转字符串中的所有元音字母，并返回结果字符串。
 * <p>
 * 元音字母包括 'a'、'e'、'i'、'o'、'u'，且可能以大小写两种形式出现不止一次。
 */
public class ReverseVowels {

    private static final Set<Character> VOWEL_SET = Stream.of('a', 'e', 'i', 'o', 'u', 'A', 'E', 'I', 'O', 'U').collect(Collectors.toSet());

    public String reverseVowels(String s) {
        char[] vowelArray = s.toCharArray();
        int i = 0;
        int j = vowelArray.length - 1;
        while (i < j) {
            while (!isVowel(vowelArray[i]) && i < j) {
                i++;
            }
            while (!isVowel(vowelArray[j]) && i < j) {
                j--;
            }
            if (i == j) {
                break;
            }
            swap(vowelArray, i, j);
            i++;
            j--;
        }
        return new String(vowelArray);
    }

    private void swap(char[] arr, int i, int j) {
        char tmp;
        tmp = arr[i];
        arr[i] = arr[j];
        arr[j] = tmp;
    }

    private boolean isVowel(char c) {
        return VOWEL_SET.contains(c);
    }

    public static void main(String[] args) {
        ReverseVowels reverseVowels = new ReverseVowels();
        String s = "hello";
        AssertUtils.equals("holle", reverseVowels.reverseVowels(s));
        s = "leetcode";
        AssertUtils.equals("leotcede", reverseVowels.reverseVowels(s));
    }
}
