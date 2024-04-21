package com.leetcode.samples.moveZeroes;

/**
 * 283. 移动零
 * <p>
 * 提示
 * 给定一个数组 nums，编写一个函数将所有 0 移动到数组的末尾，同时保持非零元素的相对顺序。
 * <p>
 * 请注意 ，必须在不复制数组的情况下原地对数组进行操作。
 */
public class MoveZeroes {

    public void moveZeroes(int[] nums) {
        if (nums.length < 2) {
            return;
        }
        int ptr = 0;
        int len = nums.length;
        for (int i = 0; i < len; i++) {
            if (nums[i] != 0) {
                nums[ptr] = nums[i];
                ptr++;
            }
        }
        if (ptr < len) {
            for (int i = ptr; i < len; i++) {
                nums[i] = 0;
            }
        }
    }
}
