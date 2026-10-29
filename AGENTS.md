# Polyglot project guidance

- Keep the backend a modular monolith. For new features, preserve API, application, and persistence boundaries.
- Use Flyway for schema changes; keep Hibernate `ddl-auto` set to `validate`.
- Keep Flutter HTTP calls in the feature data layer and render loading, error, empty, and success states in screens.
- Read credentials from environment variables. Compose fallback credentials are for local development only.
- Run focused backend tests with `mvn -f backend/pom.xml test`; run mobile checks from `mobile` with `flutter test` and `flutter analyze`.
- Record material architecture decisions in `docs/adr` and update the root README when startup steps change.
