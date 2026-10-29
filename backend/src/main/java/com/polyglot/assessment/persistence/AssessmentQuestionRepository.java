package com.polyglot.assessment.persistence;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface AssessmentQuestionRepository extends JpaRepository<AssessmentQuestion, Long> {
    @Query("select q from AssessmentQuestion q join GrammarConcept c on c.id = q.conceptId "
            + "order by c.orderIndex, q.orderIndex")
    List<AssessmentQuestion> findAllInCurriculumOrder();
}
