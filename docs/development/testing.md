# Testing and checks

Run from the repository root unless noted:

```powershell
mvn -f backend/pom.xml test
cd mobile
flutter test
flutter analyze
```

The backend suite includes Testcontainers PostgreSQL integration tests that apply all Flyway migrations, verify each A1 lesson has ten translated examples and five practice questions, exercise registration and assessment, verify progress persistence/idempotent completion, and check assessment-session and progress isolation between users. Unit tests also cover assessment service rules, grammar API/service behavior, identity service behavior, and topic-progress calculations. Flutter tests cover assessment and lesson screens, auth and learning-path APIs, onboarding, and the home screen.

Docker must be available when running the backend suite because Testcontainers starts an isolated PostgreSQL instance. No GitHub Actions workflow is configured yet, so these checks currently run locally only.
