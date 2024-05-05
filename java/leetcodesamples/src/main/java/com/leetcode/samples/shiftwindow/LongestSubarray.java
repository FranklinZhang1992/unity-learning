package com.leetcode.samples.shiftwindow;

import com.leetcode.samples.utils.AssertUtils;

/**
 * 1493. 删掉一个元素以后全为 1 的最长子数组
 * <p>
 * 提示
 * 给你一个二进制数组 nums ，你需要从中删掉一个元素。
 * <p>
 * 请你在删掉元素的结果数组中，返回最长的且只包含 1 的非空子数组的长度。
 * <p>
 * 如果不存在这样的子数组，请返回 0 。
 */
public class LongestSubarray {

    public int longestSubarray(int[] nums) {
        int i = 0;
        int j = 0;
        int cnt = 0;
        int ans = 0;
        while (j < nums.length) {
            if (nums[j] == 0) {
                cnt++;
            }
            j++;
            while (cnt > 1) {
                if (nums[i] == 0) {
                    cnt--;
                }
                i++;
            }
            ans = Math.max(ans, j - i - 1);

        }
        return ans;
    }

    public static void main(String[] args) {
        LongestSubarray longestSubarray = new LongestSubarray();
        int[] nums = new int[]{1, 1, 0, 1};
        AssertUtils.equals(3, longestSubarray.longestSubarray(nums));
        nums = new int[]{0, 1, 1, 1, 0, 1, 1, 0, 1};
        AssertUtils.equals(5, longestSubarray.longestSubarray(nums));
        nums = new int[]{1, 1, 1};
        AssertUtils.equals(2, longestSubarray.longestSubarray(nums));
    }
}
