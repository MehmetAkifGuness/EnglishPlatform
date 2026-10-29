package com.polyglot.grammar.persistence;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface GrammarLessonRepository extends JpaRepository<GrammarLesson, Long> {
    @EntityGraph(attributePaths = "concept")
    Optional<GrammarLesson> findByConcept_Id(Long conceptId);
}
