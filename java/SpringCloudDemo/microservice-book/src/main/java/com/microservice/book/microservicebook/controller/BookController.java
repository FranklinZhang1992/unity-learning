package com.microservice.book.microservicebook.controller;

import org.springframework.web.bind.annotation.RestControllerAdvice;

import com.microservice.book.microservicebook.model.Book;

@RestController
@
public class BookController {

    @GetMapping("/book")
    public Book getBookByAuthorId()
}
