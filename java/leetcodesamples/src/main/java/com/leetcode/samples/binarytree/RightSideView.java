package com.leetcode.samples.binarytree;

import com.leetcode.samples.utils.AssertUtils;

import java.util.Deque;
import java.util.LinkedList;
import java.util.List;

/**
 * 199. 二叉树的右视图
 * <p>
 * 给定一个二叉树的 根节点 root，想象自己站在它的右侧，按照从顶部到底部的顺序，返回从右侧所能看到的节点值。
 */
public class RightSideView {

    public List<Integer> rightSideView(TreeNode root) {
        List<Integer> list = new LinkedList<>();
        if (root == null) {
            return list;
        }
        Deque<TreeNode> queue = new LinkedList<>();
        queue.offer(root);
        while (!queue.isEmpty()) {
            int size = queue.size();
            for (int i = 0; i < size; i++) {
                TreeNode node = queue.pop();

                if (node.left != null) {
                    queue.offer(node.left);
                }
                if (node.right != null) {
                    queue.offer(node.right);
                }
                if (i == size - 1) {
                    list.add(node.val);
                }
            }
        }

        return list;
    }


    public static void main(String[] args) {
        RightSideView rightSideView = new RightSideView();

        TreeNode tree = new TreeNode(1, new TreeNode(2), new TreeNode(3));
        tree.left.right = new TreeNode(5);
        tree.right.right = new TreeNode(4);

        List<Integer> resultList = rightSideView.rightSideView(tree);
        AssertUtils.equals(3, resultList.size());
        AssertUtils.equals(1, resultList.get(0));
        AssertUtils.equals(3, resultList.get(1));
        AssertUtils.equals(4, resultList.get(2));

    }
}
