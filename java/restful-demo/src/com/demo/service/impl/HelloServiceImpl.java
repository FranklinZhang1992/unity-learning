package com.demo.service.impl;

import org.springframework.stereotype.Service;

import com.demo.service.HelloService;

@Service
public class HelloServiceImpl implements HelloService {

    @Override
    public String sayHello() {
        return "Hello World";
    }

}
