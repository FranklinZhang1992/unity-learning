package com.leetcode.samples.stack;

import com.leetcode.samples.utils.AssertUtils;

import java.util.Deque;
import java.util.LinkedList;

/**
 * 394. 字符串解码
 * <p>
 * 给定一个经过编码的字符串，返回它解码后的字符串。
 * <p>
 * 编码规则为: k[encoded_string]，表示其中方括号内部的 encoded_string 正好重复 k 次。注意 k 保证为正整数。
 * <p>
 * 你可以认为输入字符串总是有效的；输入字符串中没有额外的空格，且输入的方括号总是符合格式要求的。
 * <p>
 * 此外，你可以认为原始数据不包含数字，所有的数字只表示重复的次数 k ，例如不会出现像 3a 或 2[4] 的输入。
 */
public class DecodeString {

    public String decodeString(String s) {
        char[] cArray = s.toCharArray();
        Deque<Integer> numStack = new LinkedList<>();
        Deque<String> charStack = new LinkedList<>();
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < cArray.length; i++) {
            // 如果是字母，则直接append
            if (isChar(cArray[i])) {
                builder.append(cArray[i]);
                // 读取数字入数字栈
            } else if (isNum(cArray[i])) {
                int num = 0;
                int x = 0;
                while (cArray[i] != '[') {
                    int tmp = cArray[i] - '0';
                    num = num * 10 + tmp;
                    i++;
                    x++;
                }
                // 因为for循环本身就会+1，所以此次再回一位
                i--;
                numStack.push(num);
                // 已经暂存的字符入字符栈，并清空暂存的字符串
            } else if (cArray[i] == '[') {
                charStack.push(builder.toString());
                builder.setLength(0);
            } else if (cArray[i] == ']') {

                // 一个嵌套结束，取出栈顶的重复次数数字和字符串，进行重复处理
                int repeat = numStack.isEmpty() ? 1 : numStack.pop();
                StringBuilder tmp = new StringBuilder();
                for (int j = 0; j < repeat; j++) {
                    tmp.append(builder);
                }
                builder.setLength(0);
                builder.append(charStack.isEmpty() ? tmp : charStack.pop() + tmp);
            }
        }
        return builder.toString();
    }


    private boolean isNum(Character c) {
        return c >= '0' && c <= '9';
    }

    private boolean isChar(Character c) {
        return c >= 'a' && c <= 'z';
    }


    public static void main(String[] args) {
        DecodeString decodeString = new DecodeString();
//        AssertUtils.equals("aaabcbc", decodeString.decodeString("3[a]2[bc]"));
//        AssertUtils.equals("accaccacc", decodeString.decodeString("3[a2[c]]"));
//        AssertUtils.equals("abcabccdcdcdef", decodeString.decodeString("2[abc]3[cd]ef"));
//        AssertUtils.equals("abccdcdcdxyz", decodeString.decodeString("abc3[cd]xyz"));
        AssertUtils.equals("leetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcodeleetcode", decodeString.decodeString("100[leetcode]"));
    }
}
