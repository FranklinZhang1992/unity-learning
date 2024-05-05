package com.leetcode.samples.stack;

import com.leetcode.samples.utils.AssertUtils;

import java.util.Deque;
import java.util.LinkedList;

/**
 * 735. 小行星碰撞
 * <p>
 * 提示
 * 给定一个整数数组 asteroids，表示在同一行的小行星。
 * <p>
 * 对于数组中的每一个元素，其绝对值表示小行星的大小，正负表示小行星的移动方向（正表示向右移动，负表示向左移动）。每一颗小行星以相同的速度移动。
 * <p>
 * 找出碰撞后剩下的所有小行星。碰撞规则：两个小行星相互碰撞，较小的小行星会爆炸。如果两颗小行星大小相同，则两颗小行星都会爆炸。两颗移动方向相同的小行星，永远不会发生碰撞。
 */
public class AsteroidCollision {

    public int[] asteroidCollision(int[] asteroids) {
        Deque<Integer> stack = new LinkedList<>();
        for (int i = 0; i < asteroids.length; i++) {
            int a = asteroids[i];
            // 若栈内无小行星，或栈顶小行星与新的一个符号（方向）一致，则直接进栈
            if (stack.isEmpty() || !canHit(stack.peek(), a)) {
                stack.push(a);
                continue;
            }
            // 若栈内已经有小行星，且方向不一致，则需要依次拼大小
            while (!stack.isEmpty()) {
                // 若新的小行星绝对值大，则原栈内的消失，继续比对下一个栈内行星
                if (Math.abs(a) > Math.abs(stack.peek())) {
                    stack.pop();

                    //栈顶小行星出栈后，若剩下的不会相撞，则直接入栈
                    if (stack.isEmpty() || !canHit(stack.peek(), a)) {
                        stack.push(a);
                        break;
                    }
                    // 若两个小行星绝对值一样，则两个都消失，无需再继续判断栈内其他行星大小
                } else if (Math.abs(a) == Math.abs(stack.peek())) {
                    stack.pop();
                    break;
                    // 若栈内小行星绝对值更大，则新的消失，且无需继续循环
                } else if (Math.abs(a) < Math.abs(stack.peek())) {
                    break;
                }
            }
        }
        if (stack.isEmpty()) {
            return new int[0];
        } else {
            int size = stack.size();
            int[] res = new int[size];
            for (int i = size - 1; i >= 0; i--) {
                res[i] = stack.pop();
            }
            return res;
        }
    }

    /**
     * 判断两个小行星是否会相撞
     *
     * @param inStack
     * @param newStar
     * @return
     */
    private boolean canHit(int inStack, int newStar) {
        return inStack > 0 && newStar < 0;
    }

    public static void main(String[] args) {
        AsteroidCollision asteroidCollision = new AsteroidCollision();
        int[] asteroids = new int[]{5, 10, -5};
        int[] res = asteroidCollision.asteroidCollision(asteroids);
        AssertUtils.equals(2, res.length);
        AssertUtils.equals(5, res[0]);
        AssertUtils.equals(10, res[1]);

        asteroids = new int[]{-2, -2, 1, -2};
        res = asteroidCollision.asteroidCollision(asteroids);
        AssertUtils.equals(3, res.length);
        AssertUtils.equals(-2, res[0]);
        AssertUtils.equals(-2, res[1]);
        AssertUtils.equals(-2, res[2]);

        asteroids = new int[]{1, -2, -2, -2};
        res = asteroidCollision.asteroidCollision(asteroids);
        AssertUtils.equals(3, res.length);
        AssertUtils.equals(-2, res[0]);
        AssertUtils.equals(-2, res[1]);
        AssertUtils.equals(-2, res[2]);
    }
}
