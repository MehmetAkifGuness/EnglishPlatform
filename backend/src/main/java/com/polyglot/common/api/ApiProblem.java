package com.polyglot.common.api;

import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ProblemDetail;

import java.net.URI;

public final class ApiProblem {
    private ApiProblem() {
    }

    public static ProblemDetail create(HttpStatusCode status, String code, String detail, String path) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(status, detail);
        HttpStatus knownStatus = HttpStatus.resolve(status.value());
        problem.setTitle(knownStatus == null ? "HTTP " + status.value() : knownStatus.getReasonPhrase());
        problem.setType(URI.create("about:blank"));
        if (path != null && !path.isBlank()) problem.setInstance(URI.create(path));
        problem.setProperty("code", code);
        return problem;
    }
}
