package com.microservice.book.microservicebook.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import com.microservice.book.microservicebook.model.Book;

@RestController
@RequestMapping("book")
public class BookController {

    @GetMapping("/author/id/{id}")
    public Book getBookByAuthorId(@PathVariable Long id) {
        
    }
}
