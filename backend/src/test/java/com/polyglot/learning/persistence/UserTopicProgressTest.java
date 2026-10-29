package com.polyglot.learning.persistence;

import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class UserTopicProgressTest {
    @Test
    void accumulatesAssessmentEvidenceAndSchedulesWeakTopicsForNextDay() {
        Instant now = Instant.parse("2026-10-28T10:00:00Z");
        UserTopicProgress progress = new UserTopicProgress(UUID.randomUUID(), 1L);

        progress.recordAssessment(2, 1, now);
        progress.recordAssessment(2, 0, now.plus(4, ChronoUnit.DAYS));

        assertThat(progress.getAttemptedCount()).isEqualTo(4);
        assertThat(progress.getCorrectCount()).isEqualTo(1);
        assertThat(progress.getMasteryScore()).isEqualTo(0.25);
        assertThat(progress.getConfidence()).isEqualTo(0.5);
        assertThat(progress.getNextReviewAt()).isEqualTo(now.plus(5, ChronoUnit.DAYS));
    }

    @Test
    void schedulesMasteredTopicsForOneWeekLater() {
        Instant now = Instant.parse("2026-10-28T10:00:00Z");
        UserTopicProgress progress = new UserTopicProgress(UUID.randomUUID(), 1L);

        progress.recordAssessment(2, 2, now);

        assertThat(progress.getMasteryScore()).isEqualTo(1.0);
        assertThat(progress.getNextReviewAt()).isEqualTo(now.plus(7, ChronoUnit.DAYS));
    }
}
