package com.polyglot.assessment.persistence;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface AssessmentAnswerRepository extends JpaRepository<AssessmentAnswer, Long> {
    List<AssessmentAnswer> findAllBySessionId(UUID sessionId);

    Optional<AssessmentAnswer> findBySessionIdAndQuestionId(UUID sessionId, Long questionId);
}
