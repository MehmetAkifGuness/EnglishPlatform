package com.polyglot.assessment.application;

import org.springframework.http.HttpStatus;

public class AssessmentException extends RuntimeException {
    private final HttpStatus status;

    public AssessmentException(HttpStatus status, String message) {
        super(message);
        this.status = status;
    }

    public HttpStatus getStatus() {
        return status;
    }
}
