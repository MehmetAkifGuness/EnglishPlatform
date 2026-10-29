package com.polyglot.assessment.api;

import java.util.List;
import java.util.UUID;

public record AssessmentResultResponse(
        UUID sessionId,
        String estimatedLevel,
        double confidence,
        int correctCount,
        int questionCount,
        String recommendedConceptCode,
        List<TopicAssessmentResult> topics) {
}
