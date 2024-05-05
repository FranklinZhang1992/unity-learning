package com.leetcode.samples.prefix;

import com.leetcode.samples.utils.AssertUtils;

/**
 * 724. 寻找数组的中心下标
 * <p>
 * 给你一个整数数组 nums ，请计算数组的 中心下标 。
 * <p>
 * 数组 中心下标 是数组的一个下标，其左侧所有元素相加的和等于右侧所有元素相加的和。
 * <p>
 * 如果中心下标位于数组最左端，那么左侧数之和视为 0 ，因为在下标的左侧不存在元素。这一点对于中心下标位于数组最右端同样适用。
 * <p>
 * 如果数组有多个中心下标，应该返回 最靠近左边 的那一个。如果数组不存在中心下标，返回 -1 。
 */
public class PivotIndex {

    public int pivotIndex(int[] nums) {
        int total = 0;
        for (int i = 0; i < nums.length; i++) {
            total += nums[i];
        }
        int sum = 0;
        for (int i = 0; i < nums.length; i++) {
            if (2 * sum + nums[i] == total) {
                return i;
            }
            sum += nums[i];
        }
        return -1;
    }

    public static void main(String[] args) {
        PivotIndex pivotIndex = new PivotIndex();
        int[] nums = new int[]{1, 7, 3, 6, 5, 6};
        AssertUtils.equals(3, pivotIndex.pivotIndex(nums));
        nums = new int[]{1, 2, 3};
        AssertUtils.equals(-1, pivotIndex.pivotIndex(nums));
        nums = new int[]{2, 1, -1};
        AssertUtils.equals(0, pivotIndex.pivotIndex(nums));
    }
}
