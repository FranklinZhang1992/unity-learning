package com.leetcode.samples.binarytree;

import com.leetcode.samples.utils.AssertUtils;

public class TestMain {

    public static void main(String[] args) {
//        testMaxDepth();
//        testLeafSimilar();
//        testGoodNodes();
        testSearchBST();
    }

    private static void testSearchBST() {
        SearchBST searchBST = new SearchBST();

        TreeNode root = new TreeNode(4, new TreeNode(2), new TreeNode(7));
        root.left.left = new TreeNode(1);
        root.left.right = new TreeNode(3);
        AssertUtils.equals(root.left, searchBST.searchBST(root, 2));
        AssertUtils.equals(null, searchBST.searchBST(root, 5));
    }

    private static void testGoodNodes() {
        GetGoodNodes getGoodNodes = new GetGoodNodes();
        TreeNode root = new TreeNode(3);
        root.left = new TreeNode(1, new TreeNode(3), null);
        root.right = new TreeNode(4, new TreeNode(1), new TreeNode(5));
        AssertUtils.equals(4, getGoodNodes.goodNodes(root));

        root = new TreeNode(3);
        root.left = new TreeNode(3, new TreeNode(4), new TreeNode(2));
        AssertUtils.equals(3, getGoodNodes.goodNodes(root));

        root = new TreeNode(1);
        AssertUtils.equals(1, getGoodNodes.goodNodes(root));
    }

    private static void testLeafSimilar() {
        CheckTreeLeafSimilar checkTreeLeafSimilar = new CheckTreeLeafSimilar();

        TreeNode root1 = new TreeNode(3);
        root1.left = new TreeNode(5);
        root1.right = new TreeNode(1);
        root1.left.left = new TreeNode(6);
        root1.left.right = new TreeNode(2);
        root1.left.right.left = new TreeNode(7);
        root1.left.right.right = new TreeNode(4);
        root1.right.left = new TreeNode(9);
        root1.right.right = new TreeNode(8);

        TreeNode root2 = new TreeNode(3);
        root2.left = new TreeNode(5);
        root2.right = new TreeNode(1);
        root2.left.left = new TreeNode(6);
        root2.left.right = new TreeNode(7);
        root2.right.left = new TreeNode(4);
        root2.right.right = new TreeNode(2, new TreeNode(9), new TreeNode(8));

        AssertUtils.isTrue(checkTreeLeafSimilar.leafSimilar(root1, root2));

        root1 = new TreeNode(1, new TreeNode(2), new TreeNode(3));
        root2 = new TreeNode(1, new TreeNode(3), new TreeNode(2));
        AssertUtils.isFalse(checkTreeLeafSimilar.leafSimilar(root1, root2));
    }

    private static void testMaxDepth() {
        TreeNode root1 = new TreeNode(3);
        root1.left = new TreeNode(9);
        root1.right = new TreeNode(20, new TreeNode(15), new TreeNode(7));

        TreeNode root2 = new TreeNode(1, null, new TreeNode(2));

        GetMaxDepthOfBinaryTree getMaxDepthOfBinaryTree = new GetMaxDepthOfBinaryTree();
        AssertUtils.equals(3, getMaxDepthOfBinaryTree.maxDepth(root1));
        AssertUtils.equals(2, getMaxDepthOfBinaryTree.maxDepth(root2));
    }
}
