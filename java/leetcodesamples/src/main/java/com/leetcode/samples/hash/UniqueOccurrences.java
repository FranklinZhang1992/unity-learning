package com.leetcode.samples.hash;

import com.leetcode.samples.utils.AssertUtils;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;

/**
 * 1207. 独一无二的出现次数
 * <p>
 * 提示
 * 给你一个整数数组 arr，请你帮忙统计数组中每个数的出现次数。
 * <p>
 * 如果每个数的出现次数都是独一无二的，就返回 true；否则返回 false。
 */
public class UniqueOccurrences {

    public boolean uniqueOccurrences(int[] arr) {
        Map<Integer, Integer> map = new HashMap<>();
        for (int i = 0; i < arr.length; i++) {
            int a = arr[i];
            map.put(a, map.getOrDefault(a, 0) + 1);
        }
        return new HashSet<>(map.values()).size() == map.size();
    }

    public static void main(String[] args) {
        UniqueOccurrences uniqueOccurrences = new UniqueOccurrences();
        int[] arr = new int[]{1, 2, 2, 1, 1, 3};
        AssertUtils.isTrue(uniqueOccurrences.uniqueOccurrences(arr));
        arr = new int[]{1, 2};
        AssertUtils.isFalse(uniqueOccurrences.uniqueOccurrences(arr));
        arr = new int[]{-3, 0, 1, -3, 1, 1, 1, -3, 10, 0};
        AssertUtils.isTrue(uniqueOccurrences.uniqueOccurrences(arr));
    }
}

