# Local setup

Requirements: Java 21, Maven 3.6.3+, Docker Desktop with Compose, and Flutter stable 3.41 or newer.

From the repository root:

```powershell
mvn -f backend/pom.xml package
docker compose up --build -d
```

The API waits for PostgreSQL health and applies Flyway migrations on startup. To run Flutter on an Android emulator:

```powershell
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

Use `http://localhost:8080/api/v1` for a host browser/simulator, or the development machine's LAN IP for a physical device. Set `POSTGRES_PASSWORD` outside source control when overriding the local Compose default. See the root README for verification and shutdown commands.
