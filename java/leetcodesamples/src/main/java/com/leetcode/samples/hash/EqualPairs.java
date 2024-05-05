package com.leetcode.samples.hash;

import com.leetcode.samples.utils.AssertUtils;

import java.util.HashMap;
import java.util.Map;

/**
 * 2352. 相等行列对
 * <p>
 * 提示
 * 给你一个下标从 0 开始、大小为 n x n 的整数矩阵 grid ，返回满足 Ri 行和 Cj 列相等的行列对 (Ri, Cj) 的数目。
 * <p>
 * 如果行和列以相同的顺序包含相同的元素（即相等的数组），则认为二者是相等的。
 */
public class EqualPairs {

    public int equalPairs(int[][] grid) {
        Map<String, Integer> map = new HashMap<>();
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < grid.length; i++) {
            for (int j = 0; j < grid.length; j++) {
                builder.append(grid[i][j]).append("-");
            }
            String key = builder.toString();
            map.put(key, map.getOrDefault(key, 0) + 1);
            builder.setLength(0);
        }

        int cnt = 0;
        for (int i = 0; i < grid.length; i++) {
            for (int j = 0; j < grid.length; j++) {
                builder.append(grid[j][i]).append("-");
            }
            String key = builder.toString();
            int val = map.getOrDefault(key, 0);
            cnt += val;
            builder.setLength(0);
        }
        return cnt;
    }

    public static void main(String[] args) {
        EqualPairs equalPairs = new EqualPairs();
        int[][] grid = new int[][]{
                {3, 2, 1}, {1, 7, 6}, {2, 7, 7}
        };
        AssertUtils.equals(1, equalPairs.equalPairs(grid));

        grid = new int[][]{
                {3, 1, 2, 2}, {1, 4, 4, 5}, {2, 4, 2, 2}, {2, 4, 2, 2}
        };
        AssertUtils.equals(3, equalPairs.equalPairs(grid));
    }
}
