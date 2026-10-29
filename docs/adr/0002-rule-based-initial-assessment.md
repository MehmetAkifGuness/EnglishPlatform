# ADR 0002: Rule-based initial assessment

## Status

Accepted

## Decision

The first assessment uses a fixed, database-backed question bank with two questions per grammar concept. Sessions and submitted answers are stored per user. The API keeps answer keys private until scoring and returns an estimated A1 or A2 level, topic scores, confidence estimates, and a recommended available lesson.

## Rationale

This gives the app an explainable starting point without treating a small sample as a definitive language level. The assessment can later grow with more questions and a richer scoring model while keeping the session and answer records available for progress features.
