package com.polyglot.learning.application;

import com.polyglot.learning.persistence.UserTopicProgress;
import com.polyglot.learning.persistence.UserTopicProgressRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@Service
public class LearningProgressService {
    private final UserTopicProgressRepository progressRepository;

    public LearningProgressService(UserTopicProgressRepository progressRepository) {
        this.progressRepository = progressRepository;
    }

    @Transactional
    public void recordAssessment(UUID userId, Map<Long, TopicAssessmentEvidence> evidence, Instant completedAt) {
        evidence.forEach((conceptId, topicEvidence) -> {
            UserTopicProgress progress = progressRepository.findByUserIdAndConceptId(userId, conceptId)
                    .orElseGet(() -> new UserTopicProgress(userId, conceptId));
            progress.recordAssessment(topicEvidence.attemptedCount(),
                    topicEvidence.correctCount(), completedAt);
            progressRepository.save(progress);
        });
    }

    @Transactional
    public void recordExerciseAttempt(UUID userId, Long conceptId, boolean correct, Instant answeredAt) {
        UserTopicProgress progress = progressRepository.findByUserIdAndConceptId(userId, conceptId)
                .orElseGet(() -> new UserTopicProgress(userId, conceptId));
        progress.recordAssessment(1, correct ? 1 : 0, answeredAt);
        progressRepository.save(progress);
    }
}
