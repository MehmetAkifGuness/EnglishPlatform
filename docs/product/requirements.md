# Current product requirements

## Implemented

- Learners can register, log in, view their profile, and log out.
- The app lists seeded English grammar concepts and opens available lessons.
- Exercises accept a supported answer and return deterministic feedback.
- An authenticated learner can complete a fixed-question placement assessment.
- Assessment and exercise results update per-user topic evidence.
- The learning path reports topic progress, estimated mastery/confidence, review time, and one recommended lesson.
- Each of the five A1 topics has a Turkish explanation, ten English examples with Turkish translations, and five multiple-choice practice questions with feedback.
- The mobile client securely stores the access token and restores the account profile after restart; revoked/expired tokens are removed.

## Current limits

- The curriculum and assessment question bank are fixed and small.
- The five expanded A1 topics are a foundation, not a complete CEFR A1 grammar syllabus; the new material still needs review by an English-language educator.
- The level estimate is provisional; it is not a validated placement instrument.
- Progress uses cumulative correct/attempt counts and simple review intervals.
- No grammar relationship graph, explicit error taxonomy, spaced-review center, analytics dashboard, password reset, email verification, or account deletion flow is implemented.
- The browser secure-storage implementation is experimental and requires HTTPS or localhost; production web hosting must configure HTTPS and appropriate security headers.
