package com.polyglot.grammar.api;

public record GrammarConceptResponse(
        Long id,
        String code,
        String title,
        String description,
        String cefrLevel,
        int orderIndex,
        boolean hasLesson
) {
}
