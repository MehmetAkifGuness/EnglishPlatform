package com.polyglot.grammar.persistence;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface GrammarConceptRepository extends JpaRepository<GrammarConcept, Long> {
    List<GrammarConcept> findAllByOrderByOrderIndexAsc();

    Optional<GrammarConcept> findByCode(String code);

    @Query(value = "select c.* from grammar_concepts c "
            + "join grammar_concept_prerequisites p on p.prerequisite_concept_id = c.id "
            + "where p.concept_id = :conceptId order by c.order_index", nativeQuery = true)
    List<GrammarConcept> findPrerequisites(@Param("conceptId") Long conceptId);
}
