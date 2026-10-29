package com.polyglot.assessment.api;

import com.polyglot.assessment.application.AssessmentService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/assessments")
@SecurityRequirement(name = "bearerAuth")
public class AssessmentController {
    private final AssessmentService assessmentService;

    public AssessmentController(AssessmentService assessmentService) {
        this.assessmentService = assessmentService;
    }

    @PostMapping
    public AssessmentSessionResponse start(Authentication authentication) {
        return assessmentService.start(UUID.fromString(authentication.getName()));
    }

    @PostMapping("/{sessionId}/answers")
    public AssessmentAnswerResponse answer(
            Authentication authentication,
            @PathVariable UUID sessionId,
            @Valid @RequestBody SubmitAssessmentAnswerRequest request) {
        return assessmentService.answer(UUID.fromString(authentication.getName()), sessionId,
                request.questionId(), request.answer());
    }

    @PostMapping("/{sessionId}/complete")
    public AssessmentResultResponse complete(Authentication authentication, @PathVariable UUID sessionId) {
        return assessmentService.complete(UUID.fromString(authentication.getName()), sessionId);
    }
}
