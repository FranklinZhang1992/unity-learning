package com.leetcode.samples.stringmerge;

import com.leetcode.samples.utils.AssertUtils;

/**
 * leetcode: 1768
 */
public class TestMain {

    public static void main(String[] args) {
        MergeStringInTurn mergeStringInTurn = new MergeStringInTurn();
        AssertUtils.equals("apbqcr", mergeStringInTurn.mergeAlternately("abc","pqr"));
        AssertUtils.equals("apbqrs", mergeStringInTurn.mergeAlternately("ab","pqrs"));
        AssertUtils.equals("apbqcd", mergeStringInTurn.mergeAlternately("abcd","pq"));
    }
}
