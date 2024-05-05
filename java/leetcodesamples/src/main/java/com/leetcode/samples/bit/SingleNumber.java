package com.leetcode.samples.bit;

import com.leetcode.samples.utils.AssertUtils;

/**
 * 136. 只出现一次的数字
 * <p>
 * 给你一个 非空 整数数组 nums ，除了某个元素只出现一次以外，其余每个元素均出现两次。找出那个只出现了一次的元素。
 * <p>
 * 你必须设计并实现线性时间复杂度的算法来解决此问题，且该算法只使用常量额外空间。
 */
public class SingleNumber {

    public int singleNumber(int[] nums) {
        for (int i = 1; i < nums.length; i++) {
            nums[0] ^= nums[i];
        }
        return nums[0];
    }

    public static void main(String[] args) {
        SingleNumber singleNumber = new SingleNumber();
        int[] nums = new int[]{2, 2, 1};
        AssertUtils.equals(1, singleNumber.singleNumber(nums));

    }
}
