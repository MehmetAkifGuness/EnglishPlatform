package com.polyglot.grammar.api;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record SubmitAnswerRequest(@NotBlank @Size(max = 300) String answer) {
}
