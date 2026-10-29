package com.polyglot.assessment.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "assessment_sessions")
public class AssessmentSession {
    @Id
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "started_at", nullable = false)
    private Instant startedAt;

    @Column(name = "completed_at")
    private Instant completedAt;

    @Column(name = "correct_count")
    private Integer correctCount;

    @Column(name = "question_count")
    private Integer questionCount;

    @Column(name = "estimated_level", length = 2)
    private String estimatedLevel;

    private Double confidence;

    @Column(name = "recommended_concept_code", length = 80)
    private String recommendedConceptCode;

    protected AssessmentSession() {
    }

    public AssessmentSession(UUID userId, Instant startedAt) {
        this.id = UUID.randomUUID();
        this.userId = userId;
        this.startedAt = startedAt;
    }

    public UUID getId() {
        return id;
    }

    public boolean isCompleted() {
        return completedAt != null;
    }

    public Integer getCorrectCount() {
        return correctCount;
    }

    public Integer getQuestionCount() {
        return questionCount;
    }

    public String getEstimatedLevel() {
        return estimatedLevel;
    }

    public Double getConfidence() {
        return confidence;
    }

    public String getRecommendedConceptCode() {
        return recommendedConceptCode;
    }

    public void complete(
            Instant completedAt,
            int correctCount,
            int questionCount,
            String estimatedLevel,
            double confidence,
            String recommendedConceptCode) {
        this.completedAt = completedAt;
        this.correctCount = correctCount;
        this.questionCount = questionCount;
        this.estimatedLevel = estimatedLevel;
        this.confidence = confidence;
        this.recommendedConceptCode = recommendedConceptCode;
    }
}
