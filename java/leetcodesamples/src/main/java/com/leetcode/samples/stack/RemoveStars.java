package com.leetcode.samples.stack;

import com.leetcode.samples.utils.AssertUtils;

import java.util.Deque;
import java.util.LinkedList;

/**
 * 2390. 从字符串中移除星号
 * <p>
 * 提示
 * 给你一个包含若干星号 * 的字符串 s 。
 * <p>
 * 在一步操作中，你可以：
 * <p>
 * 选中 s 中的一个星号。
 * 移除星号 左侧 最近的那个 非星号 字符，并移除该星号自身。
 * 返回移除 所有 星号之后的字符串。
 * <p>
 * 注意：
 * <p>
 * 生成的输入保证总是可以执行题面中描述的操作。
 * 可以证明结果字符串是唯一的。
 */
public class RemoveStars {

    public String removeStars(String s) {
        Deque<Character> stack = new LinkedList<>();
        char[] cArray = s.toCharArray();
        char star = '*';
        for (int i = 0; i < cArray.length; i++) {
            char c = cArray[i];
            if (star != c) {
                stack.push(c);
            } else if (stack.peek() != null) {
                stack.pop();
            }
        }
        if (stack.isEmpty()) {
            return "";
        } else {
            char[] array = new char[stack.size()];
            for (int i = stack.size() - 1; i >= 0; i--) {
                array[i] = stack.pop();
            }
            return new String(array);
        }
    }

    public static void main(String[] args) {
        RemoveStars removeStars = new RemoveStars();
        AssertUtils.equals("lecoe", removeStars.removeStars("leet**cod*e"));
        AssertUtils.equals("", removeStars.removeStars("erase*****"));
    }
}
