package com.polyglot.assessment.api;

public record TopicAssessmentResult(
        String conceptCode,
        String conceptTitle,
        int correctCount,
        int questionCount,
        double confidence) {
}
