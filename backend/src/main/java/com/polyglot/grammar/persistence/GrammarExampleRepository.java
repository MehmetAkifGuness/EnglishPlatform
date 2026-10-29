package com.polyglot.grammar.persistence;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface GrammarExampleRepository extends JpaRepository<GrammarExample, Long> {
    List<GrammarExample> findAllByLessonIdOrderByOrderIndexAsc(Long lessonId);
}
