package com.polyglot.grammar.application;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.NOT_FOUND)
public class GrammarContentNotFoundException extends RuntimeException {
    public GrammarContentNotFoundException(String message) {
        super(message);
    }
}
