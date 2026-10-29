package com.polyglot.learning.api;

import java.util.List;

public record LearningPathResponse(
        String recommendedConceptCode,
        List<LearningPathItemResponse> items) {
}
