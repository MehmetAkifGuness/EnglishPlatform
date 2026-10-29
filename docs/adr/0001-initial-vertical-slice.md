# ADR 0001: Initial vertical slice

## Status

Accepted

## Decision

Start with one Flutter client and one Spring Boot modular monolith backed by PostgreSQL. Deliver grammar concepts as the first end-to-end feature. Keep API, application, and persistence responsibilities separate. Use Flyway as the only schema migration mechanism and let Hibernate validate the migrated schema.

## Rationale

This provides a real database-backed API and a small, testable foundation without introducing authentication, AI, or service boundaries before the product needs them. The concept code is a stable identifier that can later support progress and prerequisite relationships.
