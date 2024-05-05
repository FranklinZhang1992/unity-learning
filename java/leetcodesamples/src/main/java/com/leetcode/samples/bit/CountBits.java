package com.leetcode.samples.bit;

import com.leetcode.samples.utils.AssertUtils;

/**
 * 338. 比特位计数
 * <p>
 * 提示
 * 给你一个整数 n ，对于 0 <= i <= n 中的每个 i ，计算其二进制表示中 1 的个数 ，返回一个长度为 n + 1 的数组 ans 作为答案。
 */
public class CountBits {

    public int[] countBits(int n) {
        int[] ans = new int[n + 1];
        for (int i = 0; i <= n; i++) {
            if (i % 2 == 0) {
                ans[i] = ans[i / 2];
            } else {
                ans[i] = ans[i / 2] + 1;
            }
        }
        return ans;
    }

    public static void main(String[] args) {
        CountBits countBits = new CountBits();
        int[] ans = countBits.countBits(2);
        AssertUtils.equals(3, ans.length);
        AssertUtils.equals(0, ans[0]);
        AssertUtils.equals(1, ans[1]);
        AssertUtils.equals(1, ans[2]);

        ans = countBits.countBits(5);
        AssertUtils.equals(6, ans.length);
        AssertUtils.equals(0, ans[0]);
        AssertUtils.equals(1, ans[1]);
        AssertUtils.equals(1, ans[2]);
        AssertUtils.equals(2, ans[3]);
        AssertUtils.equals(1, ans[4]);
        AssertUtils.equals(2, ans[5]);
    }
}
