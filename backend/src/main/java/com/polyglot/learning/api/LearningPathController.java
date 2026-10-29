package com.polyglot.learning.api;

import com.polyglot.learning.application.LearningPathService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/learning-path")
@SecurityRequirement(name = "bearerAuth")
public class LearningPathController {
    private final LearningPathService learningPathService;

    public LearningPathController(LearningPathService learningPathService) {
        this.learningPathService = learningPathService;
    }

    @GetMapping
    public LearningPathResponse current(Authentication authentication) {
        return learningPathService.forUser(UUID.fromString(authentication.getName()));
    }
}
