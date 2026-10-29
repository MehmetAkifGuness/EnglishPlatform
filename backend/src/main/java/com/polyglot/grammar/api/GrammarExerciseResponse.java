package com.polyglot.grammar.api;

import com.polyglot.grammar.persistence.GrammarExercise;

import java.util.List;

public record GrammarExerciseResponse(
        Long id,
        String type,
        String prompt,
        List<String> options) {
    public static GrammarExerciseResponse from(GrammarExercise exercise) {
        return new GrammarExerciseResponse(
                exercise.getId(), exercise.getType(), exercise.getPrompt(), exercise.getOptions());
    }
}
