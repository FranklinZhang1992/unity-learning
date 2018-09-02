package com.demo.cloud.consul.provider.consultprovider;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class ConculProviderApplication {

	public static void main(String[] args) {
		SpringApplication.run(ConculProviderApplication.class, args);
	}
}
