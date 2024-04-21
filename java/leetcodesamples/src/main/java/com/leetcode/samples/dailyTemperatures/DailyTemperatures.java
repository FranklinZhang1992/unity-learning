package com.leetcode.samples.dailyTemperatures;

import java.util.Deque;
import java.util.LinkedList;

/**
 * 739. 每日温度
 *
 * 提示
 * 给定一个整数数组 temperatures ，表示每天的温度，返回一个数组 answer ，其中 answer[i] 是指对于第 i 天，下一个更高温度出现在几天后。如果气温在这之后都不会升高，请在该位置用 0 来代替。
 */
public class DailyTemperatures {

    public int[] dailyTemperatures(int[] temperatures) {
        int len = temperatures.length;
        int[] answers = new int[len];
        Deque<Integer> stack = new LinkedList<>();
        for (int i = len - 1; i >= 0; i--) {
            while (!stack.isEmpty() && temperatures[i] >= temperatures[stack.peek()]) {
                stack.pop();
            }
            if (!stack.isEmpty()) {
                answers[i] = stack.peek() - i;
            }
            stack.push(i);
        }
        return answers;
    }
}
