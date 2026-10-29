package com.polyglot.assessment.persistence;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface AssessmentSessionRepository extends JpaRepository<AssessmentSession, UUID> {
    Optional<AssessmentSession> findByIdAndUserId(UUID id, UUID userId);
}
