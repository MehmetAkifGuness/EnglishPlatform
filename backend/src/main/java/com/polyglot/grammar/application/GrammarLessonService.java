package com.polyglot.grammar.application;

import com.polyglot.grammar.api.AnswerResultResponse;
import com.polyglot.grammar.api.GrammarExampleResponse;
import com.polyglot.grammar.api.GrammarExerciseResponse;
import com.polyglot.grammar.api.GrammarLessonResponse;
import com.polyglot.grammar.persistence.GrammarConcept;
import com.polyglot.grammar.persistence.GrammarConceptRepository;
import com.polyglot.grammar.persistence.GrammarExampleRepository;
import com.polyglot.grammar.persistence.GrammarExercise;
import com.polyglot.grammar.persistence.GrammarExerciseRepository;
import com.polyglot.grammar.persistence.GrammarLesson;
import com.polyglot.grammar.persistence.GrammarLessonRepository;
import com.polyglot.learning.application.LearningProgressService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Locale;
import java.time.Instant;
import java.util.UUID;

@Service
public class GrammarLessonService {
    private final GrammarConceptRepository conceptRepository;
    private final GrammarLessonRepository lessonRepository;
    private final GrammarExampleRepository exampleRepository;
    private final GrammarExerciseRepository exerciseRepository;
    private final LearningProgressService learningProgressService;

    public GrammarLessonService(
            GrammarConceptRepository conceptRepository,
            GrammarLessonRepository lessonRepository,
            GrammarExampleRepository exampleRepository,
            GrammarExerciseRepository exerciseRepository,
            LearningProgressService learningProgressService) {
        this.conceptRepository = conceptRepository;
        this.lessonRepository = lessonRepository;
        this.exampleRepository = exampleRepository;
        this.exerciseRepository = exerciseRepository;
        this.learningProgressService = learningProgressService;
    }

    @Transactional(readOnly = true)
    public GrammarLessonResponse findLesson(String code) {
        GrammarConcept concept = conceptRepository.findByCode(code)
                .orElseThrow(() -> new GrammarContentNotFoundException("Konu bulunamadı."));
        GrammarLesson lesson = lessonRepository.findByConcept_Id(concept.getId())
                .orElseThrow(() -> new GrammarContentNotFoundException("Bu ders henüz hazır değil."));

        List<String> prerequisites = conceptRepository.findPrerequisites(concept.getId()).stream()
                .map(GrammarConcept::getTitle)
                .toList();
        List<GrammarExampleResponse> examples = exampleRepository
                .findAllByLessonIdOrderByOrderIndexAsc(lesson.getId()).stream()
                .map(example -> new GrammarExampleResponse(
                        example.getEnglishText(), example.getTurkishTranslation()))
                .toList();
        List<GrammarExerciseResponse> exercises = exerciseRepository
                .findAllByConceptIdOrderByOrderIndexAsc(concept.getId()).stream()
                .map(GrammarExerciseResponse::from)
                .toList();

        return new GrammarLessonResponse(concept.getCode(), concept.getTitle(),
                lesson.getExplanation(), prerequisites, examples, exercises);
    }

    @Transactional
    public AnswerResultResponse evaluate(UUID userId, Long exerciseId, String answer) {
        GrammarExercise exercise = exerciseRepository.findById(exerciseId)
                .orElseThrow(() -> new GrammarContentNotFoundException("Alıştırma bulunamadı."));
        String submitted = answer.trim().toLowerCase(Locale.ROOT);
        String correct = exercise.getCorrectAnswer();
        boolean isCorrect = submitted.equals(correct.trim().toLowerCase(Locale.ROOT));
        learningProgressService.recordExerciseAttempt(userId, exercise.getConceptId(),
                isCorrect, Instant.now());
        return new AnswerResultResponse(
                isCorrect,
                correct,
                exercise.getExplanation());
    }
}
