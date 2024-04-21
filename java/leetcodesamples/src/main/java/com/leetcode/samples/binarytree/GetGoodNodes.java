package com.leetcode.samples.binarytree;

import org.omg.CORBA.PRIVATE_MEMBER;

/**
 * 1448. 统计二叉树中好节点的数目
 * <p>
 * 给你一棵根为 root 的二叉树，请你返回二叉树中好节点的数目。
 * <p>
 * 「好节点」X 定义为：从根到该节点 X 所经过的节点中，没有任何节点的值大于 X 的值。
 */
public class GetGoodNodes {

    public int goodNodes(TreeNode root) {
        return doGet(root, Integer.MIN_VALUE);
    }

    private int doGet(TreeNode root, int max) {
        int newMax = Math.max(max, root.val);
        int cnt = root.val >= max ? 1 : 0;
        if (root.left != null) {
            cnt += doGet(root.left, newMax);
        }
        if (root.right != null) {
            cnt += doGet(root.right, newMax);
        }
        return cnt;
    }
}
