# Architecture overview

The system is a Flutter client and a Spring Boot modular monolith backed by PostgreSQL. Docker Compose runs PostgreSQL and the API for local development.

Backend modules currently cover grammar content, identity, assessment, and learning progress. Controllers translate HTTP requests to application services; services implement use cases; persistence packages own JPA entities and repositories. Public responses use DTO records rather than exposing entities. Flyway owns schema evolution and Hibernate runs with `ddl-auto: validate`.

Flutter code is feature-oriented. Screens render state and call feature data APIs/repositories; the API base URL is configured with `API_BASE_URL`. Assessment and curriculum decisions remain on the backend.

The initial design decisions are recorded in `docs/adr/`. Keep the modular monolith until a measured need justifies another deployment boundary.
