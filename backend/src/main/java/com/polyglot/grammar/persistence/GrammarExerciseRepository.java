package com.polyglot.grammar.persistence;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface GrammarExerciseRepository extends JpaRepository<GrammarExercise, Long> {
    List<GrammarExercise> findAllByConceptIdOrderByOrderIndexAsc(Long conceptId);
}
