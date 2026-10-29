package com.polyglot.assessment.api;

import java.util.List;
import java.util.UUID;

public record AssessmentSessionResponse(
        UUID id,
        int questionCount,
        List<AssessmentQuestionResponse> questions) {
}
