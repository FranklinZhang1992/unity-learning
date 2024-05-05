package com.leetcode.samples.list;

import com.leetcode.samples.utils.AssertUtils;

import java.util.Deque;
import java.util.LinkedList;

/**
 * 933. 最近的请求次数
 * <p>
 * 写一个 RecentCounter 类来计算特定时间范围内最近的请求。
 * <p>
 * 请你实现 RecentCounter 类：
 * <p>
 * RecentCounter() 初始化计数器，请求数为 0 。
 * int ping(int t) 在时间 t 添加一个新请求，其中 t 表示以毫秒为单位的某个时间，并返回过去 3000 毫秒内发生的所有请求数（包括新请求）。确切地说，返回在 [t-3000, t] 内发生的请求数。
 * 保证 每次对 ping 的调用都使用比之前更大的 t 值。
 */
public class RecentCounter {

    private Deque<Integer> queue = new LinkedList<>();

    public RecentCounter() {
    }

    public int ping(int t) {
        queue.offer(t);
        while (queue.peek() < t - 3000) {
            queue.poll();
        }
        return queue.size();
    }

    public static void main(String[] args) {
        RecentCounter recentCounter = new RecentCounter();
        AssertUtils.equals(1, recentCounter.ping(1));     // requests = [1]，范围是 [-2999,1]，返回 1
        AssertUtils.equals(2, recentCounter.ping(100));   // requests = [1, 100]，范围是 [-2900,100]，返回 2
        AssertUtils.equals(3, recentCounter.ping(3001));  // requests = [1, 100, 3001]，范围是 [1,3001]，返回 3
        AssertUtils.equals(3, recentCounter.ping(3002));  // requests = [1, 100, 3001, 3002]，范围是 [2,3002]，返回 3
    }
}
