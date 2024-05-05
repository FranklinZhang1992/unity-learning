package com.leetcode.samples.shiftwindow;

import com.leetcode.samples.utils.AssertUtils;

/**
 * 1004. 最大连续1的个数 III
 * <p>
 * 提示
 * 给定一个二进制数组 nums 和一个整数 k，如果可以翻转最多 k 个 0 ，则返回 数组中连续 1 的最大个数 。
 */
public class LongestOnes {

    public int longestOnes(int[] nums, int k) {
        int i = 0;
        int j = 0;
        int ans = 0;
        int cnt = 0;
        while (j < nums.length) {
            // 若新进入窗口的为0，则计次+1，同时窗口继续右移
            if (nums[j] == 0) {
                cnt++;
            }
            j++;
            // 当窗口内的0的数量超过阈值时，窗口左侧右移0，若右移后出窗口的元素为0，则计次-1
            while (cnt > k) {
                if (nums[i] == 0) {
                    cnt--;
                }
                i++;
            }
            // 对于窗口内0的数量不超过阈值的窗口，计算其宽度，并跟最终结果求max
            ans = Math.max(ans, j - i);
        }
        return ans;
    }

    public static void main(String[] args) {
        LongestOnes longestOnes = new LongestOnes();
        int[] nums = new int[]{1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0};
        AssertUtils.equals(6, longestOnes.longestOnes(nums, 2));
        nums = new int[]{0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1};
        AssertUtils.equals(10, longestOnes.longestOnes(nums, 3));
    }
}
