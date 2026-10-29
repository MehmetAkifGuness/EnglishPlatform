CREATE TABLE user_topic_progress (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
    concept_id BIGINT NOT NULL REFERENCES grammar_concepts(id) ON DELETE CASCADE,
    attempted_count INTEGER NOT NULL,
    correct_count INTEGER NOT NULL,
    mastery_score DOUBLE PRECISION NOT NULL,
    confidence DOUBLE PRECISION NOT NULL,
    last_practiced_at TIMESTAMPTZ NOT NULL,
    next_review_at TIMESTAMPTZ NOT NULL,
    UNIQUE (user_id, concept_id),
    CHECK (attempted_count > 0),
    CHECK (correct_count >= 0 AND correct_count <= attempted_count),
    CHECK (mastery_score >= 0 AND mastery_score <= 1),
    CHECK (confidence >= 0 AND confidence <= 1)
);

CREATE INDEX idx_user_topic_progress_review
    ON user_topic_progress(user_id, next_review_at);
