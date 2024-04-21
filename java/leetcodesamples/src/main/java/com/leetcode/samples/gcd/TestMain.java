package com.leetcode.samples.gcd;

import com.leetcode.samples.stringmerge.MergeStringInTurn;
import com.leetcode.samples.utils.AssertUtils;

public class TestMain {

    public static void main(String[] args) {
        GcdOfStrings gcd = new GcdOfStrings();
        AssertUtils.equals("ABC", gcd.gcdOfStrings("ABCABC","ABC"));
        AssertUtils.equals("AB", gcd.gcdOfStrings("ABABAB","ABAB"));
        AssertUtils.equals("", gcd.gcdOfStrings("LEET","CODE"));
    }
}
