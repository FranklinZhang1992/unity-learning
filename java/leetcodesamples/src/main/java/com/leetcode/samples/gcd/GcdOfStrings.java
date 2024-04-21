package com.leetcode.samples.gcd;

/**
 * 求字符串的最大公因子
 * 提示：
 * <p>
 * 1 <= str1.length, str2.length <= 1000
 * str1 和 str2 由大写英文字母组成
 */
public class GcdOfStrings {

    public String gcdOfStrings(String str1, String str2) {
        if (str2.length() < str1.length()) {
            return doGcd(str2, str1);
        }
        return doGcd(str1, str2);
    }

    private String doGcd(String shorter, String longer) {
        int i = 0;
        int j = shorter.length();

        while (i < j) {
            String subStr = shorter.substring(i, j);
            int subStrLen = subStr.length();
            if (longer.length() % subStrLen == 0 && shorter.length() % subStrLen == 0) {
                if ("".equals(longer.replaceAll(subStr, "")) && "".equals(shorter.replaceAll(subStr, ""))) {
                    return subStr;
                }
            }
            j--;

        }
        return "";
    }
}
