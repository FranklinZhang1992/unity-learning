package com.leetcode.samples.binarytree;

import java.util.LinkedList;
import java.util.List;

/**
 * 872. 叶子相似的树
 * 请考虑一棵二叉树上所有的叶子，这些叶子的值按从左到右的顺序排列形成一个 叶值序列 。
 * 举个例子，如上图所示，给定一棵叶值序列为 (6, 7, 4, 9, 8) 的树。
 * 如果有两棵二叉树的叶值序列是相同，那么我们就认为它们是 叶相似 的。
 * 如果给定的两个根结点分别为 root1 和 root2 的树是叶相似的，则返回 true；否则返回 false 。
 */
public class CheckTreeLeafSimilar {
    public boolean leafSimilar(TreeNode root1, TreeNode root2) {
        List<Integer> tree1Leafs = new LinkedList<>();
        List<Integer> tree2Leafs = new LinkedList<>();
        fillLeaf(root1, tree1Leafs);
        fillLeaf(root2, tree2Leafs);
        return cmp(tree1Leafs, tree2Leafs);
    }

    private boolean cmp(List<Integer> tree1Leafs, List<Integer> tree2Leafs) {
        if (tree1Leafs.size() != tree2Leafs.size()) {
            return false;
        }
        int len = tree1Leafs.size();
        for (int i = 0; i < len; i++) {
            if (!tree1Leafs.get(i).equals(tree2Leafs.get(i))) {
                return false;
            }
        }
        return true;
    }

    private void fillLeaf(TreeNode root, List<Integer> treeLeafs) {
        if (root == null) {
            return;
        }
        if (isLeaf(root)) {
            treeLeafs.add(root.val);
        } else {
            fillLeaf(root.left, treeLeafs);
            fillLeaf(root.right, treeLeafs);
        }
    }

    private boolean isLeaf(TreeNode root) {
        return root.left == null && root.right == null;
    }

}
