package com.leetcode.samples.findDifference;

import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 2215. 找出两数组的不同
 * <p>
 * 提示
 * 给你两个下标从 0 开始的整数数组 nums1 和 nums2 ，请你返回一个长度为 2 的列表 answer ，其中：
 * <p>
 * answer[0] 是 nums1 中所有 不 存在于 nums2 中的 不同 整数组成的列表。
 * answer[1] 是 nums2 中所有 不 存在于 nums1 中的 不同 整数组成的列表。
 * 注意：列表中的整数可以按 任意 顺序返回。
 */
public class FindDifference {

    public List<List<Integer>> findDifference(int[] nums1, int[] nums2) {

        Set<Integer> numSet1 = new HashSet<>();
        Set<Integer> numSet2 = new HashSet<>();

        for (int i : nums1) {
            numSet1.add(i);
        }
        for (int i : nums2) {
            numSet2.add(i);
        }
        List<Integer> answer0 = numSet1.stream().filter(i -> !numSet2.contains(i)).collect(Collectors.toList());
        List<Integer> answer1 = numSet2.stream().filter(i -> !numSet1.contains(i)).collect(Collectors.toList());
        List<List<Integer>> answers = new LinkedList<>();
        answers.add(answer0);
        answers.add(answer1);
        return answers;
    }
}
