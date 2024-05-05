package com.leetcode.samples.doubleptr;

import com.leetcode.samples.utils.AssertUtils;

import java.util.Arrays;

/**
 * 1679. K 和数对的最大数目
 * <p>
 * 提示
 * 给你一个整数数组 nums 和一个整数 k 。
 * <p>
 * 每一步操作中，你需要从数组中选出和为 k 的两个整数，并将它们移出数组。
 * <p>
 * 返回你可以对数组执行的最大操作数。
 */
public class MaxOperations {
    public int maxOperations(int[] nums, int k) {
        int left = 0;
        int right = nums.length - 1;
        int res = 0;
        nums = sort(nums);
        while (left < right) {
            int sum = nums[left] + nums[right];
            if (sum == k) {
                left++;
                right--;
                res++;
            } else if (sum > k) {
                right--;
            } else {
                left++;
            }
        }
        return res;
    }

    private int[] sort(int[] nums) {
        return Arrays.stream(nums).sorted().toArray();
    }

    public static void main(String[] args) {
        MaxOperations maxOperations = new MaxOperations();
        int[] nums = new int[]{1, 2, 3, 4};
        AssertUtils.equals(2, maxOperations.maxOperations(nums, 5));
    }

}
