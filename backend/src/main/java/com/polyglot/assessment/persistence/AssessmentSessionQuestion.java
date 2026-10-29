package com.polyglot.assessment.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.util.UUID;

@Entity
@Table(name = "assessment_session_questions")
public class AssessmentSessionQuestion {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "session_id", nullable = false)
    private UUID sessionId;

    @Column(name = "question_id", nullable = false)
    private Long questionId;

    @Column(name = "order_index", nullable = false)
    private int orderIndex;

    protected AssessmentSessionQuestion() {
    }

    public AssessmentSessionQuestion(UUID sessionId, Long questionId, int orderIndex) {
        this.sessionId = sessionId;
        this.questionId = questionId;
        this.orderIndex = orderIndex;
    }

    public Long getQuestionId() {
        return questionId;
    }
}
