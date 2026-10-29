package com.polyglot.assessment.api;

import java.util.List;

public record AssessmentQuestionResponse(
        Long id,
        String conceptCode,
        String conceptTitle,
        String prompt,
        List<String> options) {
}
