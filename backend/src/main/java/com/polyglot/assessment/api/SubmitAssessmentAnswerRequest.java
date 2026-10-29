package com.polyglot.assessment.api;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record SubmitAssessmentAnswerRequest(
        @NotNull Long questionId,
        @NotBlank @Size(max = 300) String answer) {
}
