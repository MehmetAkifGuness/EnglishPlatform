package com.polyglot.grammar.application;

import com.polyglot.grammar.persistence.GrammarConceptRepository;
import com.polyglot.grammar.persistence.GrammarExampleRepository;
import com.polyglot.grammar.persistence.GrammarExercise;
import com.polyglot.grammar.persistence.GrammarExerciseRepository;
import com.polyglot.grammar.persistence.GrammarLessonRepository;
import com.polyglot.learning.application.LearningProgressService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GrammarLessonServiceTest {
    @Mock
    private GrammarConceptRepository conceptRepository;
    @Mock
    private GrammarLessonRepository lessonRepository;
    @Mock
    private GrammarExampleRepository exampleRepository;
    @Mock
    private GrammarExerciseRepository exerciseRepository;
    @Mock
    private LearningProgressService learningProgressService;
    @InjectMocks
    private GrammarLessonService service;

    @Test
    void evaluatesAnswerWithoutDependingOnCapitalizationOrSurroundingSpaces() {
        GrammarExercise exercise = mock(GrammarExercise.class);
        when(exerciseRepository.findById(7L)).thenReturn(Optional.of(exercise));
        when(exercise.getConceptId()).thenReturn(11L);
        when(exercise.getCorrectAnswer()).thenReturn("I drink coffee.");
        when(exercise.getExplanation()).thenReturn("Özne + Fiil + Nesne.");

        UUID userId = UUID.randomUUID();
        var result = service.evaluate(userId, 7L, "  i drink coffee.  ");

        assertThat(result.correct()).isTrue();
        assertThat(result.correctAnswer()).isEqualTo("I drink coffee.");
        verify(learningProgressService).recordExerciseAttempt(
                eq(userId), eq(11L), eq(true), any(java.time.Instant.class));
        var incorrectResult = service.evaluate(userId, 7L, "I drinks coffee.");
        assertThat(incorrectResult.correct()).isFalse();
        verify(learningProgressService).recordExerciseAttempt(
                eq(userId), eq(11L), eq(false), any(java.time.Instant.class));
        assertThat(result.explanation()).isEqualTo("Özne + Fiil + Nesne.");
    }
}
