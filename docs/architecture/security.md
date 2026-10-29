# Security notes

Registration and login are public. Passwords are stored through Spring's delegating password encoder. The server issues random bearer tokens, stores their SHA-256 hashes with expiry timestamps, and checks them for authenticated requests. The Flutter client stores only the access token using `flutter_secure_storage`; it restores the profile from the server at startup and removes expired/revoked tokens. Logout revokes the server-side session and clears local storage. User-specific assessment and progress operations derive the user ID from the authenticated principal.

Authentication and authorization errors return RFC 9457 Problem Details JSON. OpenAPI documents protected operations using the bearer scheme. The API docs can be disabled with `SPRINGDOC_API_DOCS_ENABLED=false` and `SPRINGDOC_SWAGGER_UI_ENABLED=false`.

Grammar concept and lesson reads are public. Actuator exposes only health. Database credentials can be set with `POSTGRES_PASSWORD`, `DB_URL`, `DB_USERNAME`, and `DB_PASSWORD`; Compose's default password is for local development only. Local CORS origins are configured in `application.yml` and can be overridden with `CORS_ALLOWED_ORIGIN_PATTERNS`.

Before deployment, configure HTTPS and managed secrets, review token expiry/revocation behavior and rate limiting, define account deletion and data retention, and run a security review. The secure-storage web implementation requires HTTPS or localhost and is experimental; use HTTPS and the required security headers in deployed web builds. This document does not claim production security certification.
