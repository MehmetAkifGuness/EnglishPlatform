package com.polyglot.learning.persistence;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserTopicProgressRepository extends JpaRepository<UserTopicProgress, UUID> {
    List<UserTopicProgress> findAllByUserId(UUID userId);

    Optional<UserTopicProgress> findByUserIdAndConceptId(UUID userId, Long conceptId);
}
