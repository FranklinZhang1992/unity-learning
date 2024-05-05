package com.leetcode.samples.linklist;

import com.leetcode.samples.utils.AssertUtils;

public class ReverseList {

    public ListNode reverseList(ListNode head) {
        if (head == null) {
            return null;
        }
        ListNode pre = null;
        ListNode current = head;
        while (current != null) {
            ListNode nextTmp = current.next;
            current.next = pre;
            pre = current;
            current = nextTmp;
        }
        return pre;
    }


    public static void main(String[] args) {
        ReverseList reverseList = new ReverseList();
        ListNode head = new ListNode(1, new ListNode(2, new ListNode(3, new ListNode(4, new ListNode(5)))));
        ListNode result = reverseList.reverseList(head);
        ListNode ptr = result;
        for (int i = 5; i > 0; i--) {
            AssertUtils.equals(i, ptr.val);
            ptr = ptr.next;

        }
    }

}
