package com.polyglot.grammar.api;

import com.polyglot.grammar.application.GrammarLessonService;
import jakarta.validation.Valid;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
public class GrammarLessonController {
    private final GrammarLessonService lessonService;

    public GrammarLessonController(GrammarLessonService lessonService) {
        this.lessonService = lessonService;
    }

    @GetMapping("/grammar-concepts/{code}/lesson")
    public GrammarLessonResponse lesson(@PathVariable String code) {
        return lessonService.findLesson(code);
    }

    @PostMapping("/exercises/{exerciseId}/answers")
    @SecurityRequirement(name = "bearerAuth")
    public AnswerResultResponse answer(
            Authentication authentication,
            @PathVariable Long exerciseId,
            @Valid @RequestBody SubmitAnswerRequest request) {
        return lessonService.evaluate(UUID.fromString(authentication.getName()), exerciseId,
                request.answer());
    }
}
