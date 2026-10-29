# Polyglot

Polyglot is an English-learning mobile app with a Flutter client and a Spring Boot modular monolith backed by PostgreSQL.

## Current scope

- Public grammar-concept catalog and lesson content, including answer evaluation
- Email/password registration, login, profile, and logout with persisted, expiring bearer sessions
- Mobile bearer tokens stored in platform secure storage and restored after restart
- Fixed-question placement assessment with estimated level, topic evidence, and a recommended lesson
- Per-user topic progress and a deterministic learning path with review timing
- PostgreSQL schema and seed content managed by ten Flyway migrations
- Five A1 grammar lessons with ten translated examples and five practice questions each
- Flutter onboarding, authentication, home/learning path, lessons, assessment, and profile screens
- Loading, error, empty, and success states on data-backed screens

## Requirements

- Java 21 and Maven 3.6.3+
- PostgreSQL 17.11 (provided by Compose)
- Docker Desktop with Docker Compose
- Flutter stable (3.41 or newer; the local SDK is 3.41.3)

## Start the API and database

From the repository root, package the API first, then start the database and API containers:

```powershell
mvn -f backend/pom.xml package
docker compose up --build -d
```

Compose waits for PostgreSQL to become healthy before starting the API. Flyway applies migrations at startup and Hibernate validates the schema. Verify:

```powershell
Invoke-RestMethod http://localhost:8080/actuator/health
Invoke-RestMethod http://localhost:8080/api/v1/grammar-concepts
```

The Compose password default is for local development only. Set `POSTGRES_PASSWORD` in the shell before starting Compose when using a non-local environment. To stop the services, run `docker compose down`; add `-v` only when you intend to delete the local database volume.

To run the API outside Docker, start PostgreSQL with Compose (`docker compose up -d database`), then run `mvn -f backend/pom.xml spring-boot:run` from the repository root. Flyway applies migrations on startup; Hibernate validates the resulting schema. Rebuild the JAR and container after backend changes by rerunning the package and Compose commands.

## Run Flutter

```powershell
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

`10.0.2.2` is the Android emulator's host alias. For Chrome or the iOS simulator, use `http://localhost:8080/api/v1`; for a physical device, use the development machine's LAN IP. The base URL defaults to localhost and can be changed with `--dart-define=API_BASE_URL=...`. Local web origins on `localhost` and `127.0.0.1` are allowed by default; set `CORS_ALLOWED_ORIGIN_PATTERNS` to the deployed client origins outside local development.

## Implemented API routes

All routes use the `/api/v1` prefix. Grammar catalog and lesson reads are public; assessment, progress, profile, logout, and exercise-answer routes require a bearer token.

| Method | Route | Access |
| --- | --- | --- |
| GET | `/actuator/health` | Public |
| POST | `/api/v1/auth/register` | Public |
| POST | `/api/v1/auth/login` | Public |
| DELETE | `/api/v1/auth/logout` | Authenticated |
| GET | `/api/v1/profile` | Authenticated |
| GET | `/api/v1/grammar-concepts` | Public |
| GET | `/api/v1/grammar-concepts/{code}/lesson` | Public |
| POST | `/api/v1/exercises/{exerciseId}/answers` | Authenticated |
| POST | `/api/v1/assessments` | Authenticated |
| POST | `/api/v1/assessments/{sessionId}/answers` | Authenticated |
| POST | `/api/v1/assessments/{sessionId}/complete` | Authenticated |
| GET | `/api/v1/learning-path` | Authenticated |

## API documentation

With the local API running, open `http://localhost:8080/swagger-ui.html` for interactive documentation or `http://localhost:8080/v3/api-docs` for the OpenAPI JSON contract. Disable both endpoints in an environment where API documentation should not be exposed by setting `SPRINGDOC_API_DOCS_ENABLED=false` and `SPRINGDOC_SWAGGER_UI_ENABLED=false`.

## Validate

```powershell
mvn -f backend/pom.xml test
cd mobile
flutter test
flutter analyze
```

## Architecture decision

The backend is a modular monolith. Grammar concepts cross the API boundary through response records; application services own use cases while Spring Data JPA stays in persistence packages. PostgreSQL schema changes are versioned with Flyway and Hibernate schema generation is disabled. The mobile app keeps HTTP calls in feature data layers. See `docs/` for current boundaries, data model, security notes, and known limitations.
