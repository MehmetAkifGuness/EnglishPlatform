package com.polyglot.assessment.persistence;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface AssessmentSessionQuestionRepository extends JpaRepository<AssessmentSessionQuestion, Long> {
    List<AssessmentSessionQuestion> findAllBySessionIdOrderByOrderIndexAsc(UUID sessionId);

    boolean existsBySessionIdAndQuestionId(UUID sessionId, Long questionId);
}
