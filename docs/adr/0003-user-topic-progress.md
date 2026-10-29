# ADR 0003: User-specific topic progress

## Status

Accepted

## Decision

Store per-user topic attempt and correct counts after an assessment is completed and whenever a learner answers a lesson exercise. Derive mastery from cumulative correct answers and expose confidence and the next review time through an authenticated learning path. Schedule review after one, three, or seven days based on mastery bands.

## Rationale

This provides a simple, explainable first version of personalization using assessment and practice results. The scores are provisional because the initial assessment has only two questions per topic; exercise attempts improve the evidence without changing the learning path response shape.
