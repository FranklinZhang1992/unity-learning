package com.leetcode.samples.candies;

import java.util.LinkedList;
import java.util.List;

/**
 * 1431. 拥有最多糖果的孩子
 *
 * 给你一个数组 candies 和一个整数 extraCandies ，其中 candies[i] 代表第 i 个孩子拥有的糖果数目。
 *
 * 对每一个孩子，检查是否存在一种方案，将额外的 extraCandies 个糖果分配给孩子们之后，此孩子有 最多 的糖果。注意，允许有多个孩子同时拥有 最多 的糖果数目。
 */
public class KidsWithCandies {
    public List<Boolean> kidsWithCandies(int[] candies, int extraCandies) {
        int max = 0;
        for (int candy : candies) {
            max = Math.max(max, candy);
        }

        List<Boolean> result = new LinkedList<>();
        for (int candy : candies) {
            result.add(max - candy <= extraCandies);
        }
        return result;
    }
}
