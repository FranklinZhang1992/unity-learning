package com.demo.plugins;

import com.demo.utils.LogUtil;

public abstract class AbstractPluginBase implements Plugin {

    public String getPluginName() {
        String fullName = getClass().getName();
        return fullName.substring(fullName.lastIndexOf('.') + 1);
    }

    /*
     * (non-Javadoc)
     * 
     * @see com.demo.plugins.Plugin#start()
     */
    @Override
    public void start() {
        startImpl();
        LogUtil.log(getPluginName() + " started.");
    }

    /*
     * (non-Javadoc)
     * 
     * @see com.demo.plugins.Plugin#stop()
     */
    @Override
    public void stop() {
        stopImpl();
        LogUtil.log(getPluginName() + " stopped.");
    }

    protected abstract void startImpl();

    protected abstract void stopImpl();

}
