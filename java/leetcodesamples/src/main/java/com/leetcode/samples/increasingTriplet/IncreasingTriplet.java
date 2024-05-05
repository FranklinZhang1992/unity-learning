package com.leetcode.samples.increasingTriplet;

import com.leetcode.samples.utils.AssertUtils;

/**
 * 334. 递增的三元子序列
 * <p>
 * 给你一个整数数组 nums ，判断这个数组中是否存在长度为 3 的递增子序列。
 * <p>
 * 如果存在这样的三元组下标 (i, j, k) 且满足 i < j < k ，使得 nums[i] < nums[j] < nums[k] ，返回 true ；否则，返回 false 。
 */
public class IncreasingTriplet {

    public boolean increasingTriplet(int[] nums) {
        if (nums.length < 3) {
            return false;
        }
        int first = nums[0];
        int second = Integer.MAX_VALUE;
        for (int i = 1; i < nums.length; i++) {
            if (nums[i] > second) {
                return true;
            } else if (nums[i] > first) {
                second = nums[i];
            } else {
                first = nums[i];
            }
        }
        return false;
    }

    public static void main(String[] args) {
        IncreasingTriplet increasingTriplet = new IncreasingTriplet();
        int[] nums = new int[]{1, 2, 3, 4, 5};
        AssertUtils.isTrue(increasingTriplet.increasingTriplet(nums));
        nums = new int[]{5, 4, 3, 2, 1};
        AssertUtils.isFalse(increasingTriplet.increasingTriplet(nums));
        nums = new int[]{2, 1, 5, 0, 4, 6};
        AssertUtils.isTrue(increasingTriplet.increasingTriplet(nums));
        nums = new int[]{20, 100, 10, 12, 5, 13};
        AssertUtils.isTrue(increasingTriplet.increasingTriplet(nums));
        nums = new int[]{1, 2, 1, 3};
        AssertUtils.isTrue(increasingTriplet.increasingTriplet(nums));
        nums = new int[]{1, 5, 0, 4, 1, 3};
        AssertUtils.isTrue(increasingTriplet.increasingTriplet(nums));
    }
}
