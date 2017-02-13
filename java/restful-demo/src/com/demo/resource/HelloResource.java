package com.demo.resource;

import javax.annotation.Resource;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.springframework.stereotype.Component;

import com.demo.service.HelloService;


@Component
@Path("hello")
public class HelloResource {
    
    @Resource
    private HelloService helloService;
    
    //    GET http://localhost:8080/restful-demo/hello/method1
    @GET
    @Path("method1")
    @Produces(MediaType.TEXT_PLAIN)
    public String sayHello() {
        return helloService.sayHello();
    }
}
