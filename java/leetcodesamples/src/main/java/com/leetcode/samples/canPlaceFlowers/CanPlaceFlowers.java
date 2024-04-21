package com.leetcode.samples.canPlaceFlowers;

import com.leetcode.samples.utils.AssertUtils;

/**
 * 605. 种花问题
 * 简单
 * 相关标签
 * 相关企业
 * 假设有一个很长的花坛，一部分地块种植了花，另一部分却没有。可是，花不能种植在相邻的地块上，它们会争夺水源，两者都会死去。
 *
 * 给你一个整数数组 flowerbed 表示花坛，由若干 0 和 1 组成，其中 0 表示没种植花，1 表示种植了花。另有一个数 n ，能否在不打破种植规则的情况下种入 n 朵花？能则返回 true ，不能则返回 false 。
 */
public class CanPlaceFlowers {

    public boolean canPlaceFlowers(int[] flowerbed, int n) {
        int previousFlowerIndex = -1;
        // 最多还能种的花的数量
        int cnt = 0;
        int len = flowerbed.length;
        for (int i = 0; i < flowerbed.length; i++) {
            if (flowerbed[i] == 1) {
                if (previousFlowerIndex < 0) {
                    cnt += getMaxPlacedFlowers(i - previousFlowerIndex - 1, true);
                } else {
                    cnt += getMaxPlacedFlowers(i - previousFlowerIndex - 1, false);
                }
                previousFlowerIndex = i;
            }
            if (cnt >= n) {
                return true;
            }
        }
        if (previousFlowerIndex < 0) {
            cnt += getMaxPlacedFlowers(len - previousFlowerIndex, true);
        } else {
            cnt += getMaxPlacedFlowers(len - previousFlowerIndex - 1, true);
        }
        return cnt >= n;
    }

    private int getMaxPlacedFlowers(int interval, boolean isSide) {
        if (isSide) {
            return interval / 2;
        }
        return (interval - 1) / 2;
    }

    public static void main(String[] args) {
        CanPlaceFlowers canPlaceFlowers = new CanPlaceFlowers();
        AssertUtils.isTrue(canPlaceFlowers.canPlaceFlowers(new int[]{0}, 1));
        AssertUtils.isTrue(canPlaceFlowers.canPlaceFlowers(new int[]{1}, 0));
        AssertUtils.isTrue(canPlaceFlowers.canPlaceFlowers(new int[]{0, 0, 1}, 1));
        AssertUtils.isTrue(canPlaceFlowers.canPlaceFlowers(new int[]{1, 0, 0}, 1));
        AssertUtils.isTrue(canPlaceFlowers.canPlaceFlowers(new int[]{0, 0, 0}, 2));
        AssertUtils.isFalse(canPlaceFlowers.canPlaceFlowers(new int[]{0, 1, 0}, 1));
        AssertUtils.isTrue(canPlaceFlowers.canPlaceFlowers(new int[]{0, 0, 0, 1}, 1));
    }
}
