package com.leetcode.samples.dynamicprogramming;

import com.leetcode.samples.utils.AssertUtils;

/**
 * 714. 买卖股票的最佳时机含手续费
 * 提示
 * 给定一个整数数组 prices，其中 prices[i]表示第 i 天的股票价格 ；整数 fee 代表了交易股票的手续费用。
 * <p>
 * 你可以无限次地完成交易，但是你每笔交易都需要付手续费。如果你已经购买了一个股票，在卖出它之前你就不能再继续购买股票了。
 * <p>
 * 返回获得利润的最大值。
 * <p>
 * 注意：这里的一笔交易指买入持有并卖出股票的整个过程，每笔交易你只需要为支付一次手续费。
 */
public class MaxProfit {

    public int maxProfit(int[] prices, int fee) {
        int[][] dp = new int[prices.length][2];
        // dp[i][0] 表示第i天不持有股票
        // dp[i][1] 表示第i天持有股票
        dp[0][0] = 0;
        dp[0][1] = -prices[0];
        for (int i = 1; i < prices.length; i++) {
            dp[i][0] = Math.max(dp[i - 1][0], dp[i - 1][1] + prices[i] - fee);
            dp[i][1] = Math.max(dp[i - 1][1], dp[i - 1][0] - prices[i]);
        }
        // 最後一天不持有股票錢永遠比持有股票高
        return dp[prices.length - 1][0];
    }

    public static void main(String[] args) {
        MaxProfit maxProfit = new MaxProfit();
        int[] prices = new int[]{1, 3, 2, 8, 4, 9};
        AssertUtils.equals(8, maxProfit.maxProfit(prices, 2));
        prices = new int[]{1, 3, 7, 5, 10, 3};
        AssertUtils.equals(6, maxProfit.maxProfit(prices, 3));
    }
}
