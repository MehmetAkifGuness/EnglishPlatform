package com.polyglot.grammar.api;

public record AnswerResultResponse(boolean correct, String correctAnswer, String explanation) {
}
