package com.polyglot.grammar.api;

import java.util.List;

public record GrammarLessonResponse(
        String conceptCode,
        String title,
        String explanation,
        List<String> prerequisites,
        List<GrammarExampleResponse> examples,
        List<GrammarExerciseResponse> exercises) {
}
