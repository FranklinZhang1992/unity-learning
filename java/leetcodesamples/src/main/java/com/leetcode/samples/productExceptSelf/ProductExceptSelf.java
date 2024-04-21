package com.leetcode.samples.productExceptSelf;

/**
 * 238. 除自身以外数组的乘积
 * <p>
 * 提示
 * 给你一个整数数组 nums，返回 数组 answer ，其中 answer[i] 等于 nums 中除 nums[i] 之外其余各元素的乘积 。
 * <p>
 * 题目数据 保证 数组 nums之中任意元素的全部前缀元素和后缀的乘积都在  32 位 整数范围内。
 * <p>
 * 请 不要使用除法，且在 O(n) 时间复杂度内完成此题。
 */
public class ProductExceptSelf {

    public int[] productExceptSelf(int[] nums) {
        int left = 1;
        int right = 1;
        int len = nums.length;
        int[] answer = new int[len];
        for (int i = 0; i < answer.length; i++) {
            answer[i] = 1;
        }

        for (int i = 0; i < len; i++) {
            answer[i] *= left;
            left = left * nums[i];
            answer[len - i -1] = answer[len - i -1] * right;
            right = right * nums[len - i -1];
        }
        return answer;
    }

    public static void main(String[] args) {
        ProductExceptSelf productExceptSelf = new ProductExceptSelf();
        int[] res = productExceptSelf.productExceptSelf(new int[]{1,2,3,4});
        for (int re : res) {
            System.out.println(re);
        }
    }
}
