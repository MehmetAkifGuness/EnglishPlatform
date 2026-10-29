package com.polyglot.learning.api;

import java.time.Instant;

public record LearningPathItemResponse(
        String code,
        String title,
        String description,
        String cefrLevel,
        int orderIndex,
        boolean hasLesson,
        Integer attemptedCount,
        Integer correctCount,
        Double masteryScore,
        Double confidence,
        Instant lastPracticedAt,
        Instant nextReviewAt,
        String status,
        boolean recommended) {
}
