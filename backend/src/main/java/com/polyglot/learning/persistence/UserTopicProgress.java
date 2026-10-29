package com.polyglot.learning.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "user_topic_progress")
public class UserTopicProgress {
    @Id
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "concept_id", nullable = false)
    private Long conceptId;

    @Column(name = "attempted_count", nullable = false)
    private int attemptedCount;

    @Column(name = "correct_count", nullable = false)
    private int correctCount;

    @Column(name = "mastery_score", nullable = false)
    private double masteryScore;

    @Column(nullable = false)
    private double confidence;

    @Column(name = "last_practiced_at", nullable = false)
    private Instant lastPracticedAt;

    @Column(name = "next_review_at", nullable = false)
    private Instant nextReviewAt;

    protected UserTopicProgress() {
    }

    public UserTopicProgress(UUID userId, Long conceptId) {
        this.id = UUID.randomUUID();
        this.userId = userId;
        this.conceptId = conceptId;
    }

    public void recordAssessment(int attempts, int correct, Instant now) {
        attemptedCount += attempts;
        correctCount += correct;
        masteryScore = correctCount / (double) attemptedCount;
        confidence = Math.min(0.9, attemptedCount / 8.0);
        lastPracticedAt = now;
        long reviewDays = masteryScore < 0.5 ? 1 : masteryScore < 0.8 ? 3 : 7;
        nextReviewAt = now.plusSeconds(reviewDays * 24 * 60 * 60);
    }

    public Long getConceptId() {
        return conceptId;
    }

    public int getAttemptedCount() {
        return attemptedCount;
    }

    public int getCorrectCount() {
        return correctCount;
    }

    public double getMasteryScore() {
        return masteryScore;
    }

    public double getConfidence() {
        return confidence;
    }

    public Instant getLastPracticedAt() {
        return lastPracticedAt;
    }

    public Instant getNextReviewAt() {
        return nextReviewAt;
    }
}
