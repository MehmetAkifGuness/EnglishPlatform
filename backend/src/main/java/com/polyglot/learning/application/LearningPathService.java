package com.polyglot.learning.application;

import com.polyglot.grammar.persistence.GrammarConcept;
import com.polyglot.grammar.persistence.GrammarConceptRepository;
import com.polyglot.learning.api.LearningPathItemResponse;
import com.polyglot.learning.api.LearningPathResponse;
import com.polyglot.learning.persistence.UserTopicProgress;
import com.polyglot.learning.persistence.UserTopicProgressRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class LearningPathService {
    private final GrammarConceptRepository conceptRepository;
    private final UserTopicProgressRepository progressRepository;

    public LearningPathService(
            GrammarConceptRepository conceptRepository,
            UserTopicProgressRepository progressRepository) {
        this.conceptRepository = conceptRepository;
        this.progressRepository = progressRepository;
    }

    @Transactional(readOnly = true)
    public LearningPathResponse forUser(UUID userId) {
        Instant now = Instant.now();
        List<GrammarConcept> concepts = conceptRepository.findAllByOrderByOrderIndexAsc();
        Map<Long, UserTopicProgress> progressByConcept = progressRepository.findAllByUserId(userId).stream()
                .collect(Collectors.toMap(UserTopicProgress::getConceptId, Function.identity()));

        String recommendedCode = concepts.stream()
                .filter(GrammarConcept::hasLesson)
                .filter(concept -> {
                    UserTopicProgress progress = progressByConcept.get(concept.getId());
                    return progress != null && progress.getMasteryScore() < 0.8
                            && !progress.getNextReviewAt().isAfter(now);
                })
                .map(GrammarConcept::getCode)
                .findFirst()
                .orElseGet(() -> concepts.stream()
                        .filter(GrammarConcept::hasLesson)
                        .filter(concept -> {
                            UserTopicProgress progress = progressByConcept.get(concept.getId());
                            return progress == null || progress.getMasteryScore() < 0.8;
                        })
                        .min(Comparator.<GrammarConcept>comparingDouble(concept -> {
                            UserTopicProgress progress = progressByConcept.get(concept.getId());
                            return progress == null ? -1.0 : progress.getMasteryScore();
                        }).thenComparingInt(GrammarConcept::getOrderIndex))
                        .map(GrammarConcept::getCode)
                        .orElseGet(() -> concepts.stream().filter(GrammarConcept::hasLesson)
                                .map(GrammarConcept::getCode).findFirst().orElse(null)));

        List<LearningPathItemResponse> items = concepts.stream()
                .map(concept -> toItem(concept, progressByConcept.get(concept.getId()),
                        concept.getCode().equals(recommendedCode), now))
                .toList();
        return new LearningPathResponse(recommendedCode, items);
    }

    private static LearningPathItemResponse toItem(
            GrammarConcept concept, UserTopicProgress progress, boolean recommended, Instant now) {
        String status;
        if (progress == null) {
            status = "YENİ";
        } else if (progress.getMasteryScore() >= 0.8) {
            status = "YETERLİ";
        } else if (!progress.getNextReviewAt().isAfter(now)) {
            status = "TEKRAR_ZAMANI";
        } else {
            status = "GELİŞİYOR";
        }
        return new LearningPathItemResponse(
                concept.getCode(), concept.getTitle(), concept.getDescription(),
                concept.getCefrLevel(), concept.getOrderIndex(), concept.hasLesson(),
                progress == null ? null : progress.getAttemptedCount(),
                progress == null ? null : progress.getCorrectCount(),
                progress == null ? null : progress.getMasteryScore(),
                progress == null ? null : progress.getConfidence(),
                progress == null ? null : progress.getLastPracticedAt(),
                progress == null ? null : progress.getNextReviewAt(), status, recommended);
    }
}
