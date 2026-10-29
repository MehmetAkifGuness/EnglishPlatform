# Data model

Flyway migrations `V1`–`V10` define the current PostgreSQL schema and seed content. The model includes grammar concepts, lessons and exercises, users and authentication sessions, assessment questions/sessions/answers, and per-user topic progress. V10 expands A1 lesson explanations, examples, and practice without changing the schema.

Concept codes are stable identifiers used by the API and client. Assessment questions and exercises point to concepts. Assessment sessions and answers are user-owned. `user_topic_progress` stores one cumulative attempted/correct count and derived mastery, confidence, last-practiced time, and next-review time per user and concept.

The current model does not yet include typed grammar-concept edges, multi-concept exercise mappings, explicit error annotations, or a general decision log. Add those through new Flyway migrations when a feature needs them; never edit an already-applied migration.

Learning and assessment history is retained in the database indefinitely in this initial version. A retention and account-deletion policy remains to be designed before production use.
