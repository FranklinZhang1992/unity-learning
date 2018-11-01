package com.demo;

import java.util.ArrayList;
import java.util.List;

import com.demo.plugins.MainPlugin;
import com.demo.plugins.Plugin;
import com.demo.plugins.PostPlugin;
import com.demo.utils.LogUtil;

public class Main {

    public static void main(String[] args) {
        List<Plugin> plugins = new ArrayList<Plugin>();
        plugins.add(new MainPlugin());
        plugins.add(new PostPlugin());

        for (Plugin p : plugins) {
            p.start();
        }

        LogUtil.log("all plugins started");
    }

}
