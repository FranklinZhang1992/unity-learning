package com.example.db.mock;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

public class MockDBEngine {

    private static MockDBEngine _instance = null;
    private Map<String, Object> db = null;
    private long keySeed = 0;

    public synchronized static MockDBEngine instance() {
        if (_instance == null) {
            _instance = new MockDBEngine();
        }
        return _instance;
    }

    private MockDBEngine() {
        db = new HashMap<String, Object>();
    }

    private long genKey() {
        return keySeed++;
    }

    public synchronized Object save(Object obj) {
        long id = -1L;
        try {
            Method getIdMethod = obj.getClass().getMethod("getId");
            if (getIdMethod != null) {
                Object idObj = getIdMethod.invoke(obj);
                if (idObj != null) {
                    id = (Long) idObj;
                }
                if (id < 0L) {
                    id = genKey();
                }

            }
        } catch (NoSuchMethodException | SecurityException | IllegalAccessException | IllegalArgumentException
                | InvocationTargetException e) {
            e.printStackTrace();
        }

    }
}
