package com.polyglot.identity.application;

import com.polyglot.identity.api.AuthResponse;
import com.polyglot.identity.api.LoginRequest;
import com.polyglot.identity.api.RegisterRequest;
import com.polyglot.identity.api.UserProfileResponse;
import com.polyglot.identity.persistence.AppUser;
import com.polyglot.identity.persistence.AppUserRepository;
import com.polyglot.identity.persistence.AuthSession;
import com.polyglot.identity.persistence.AuthSessionRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.util.Locale;
import java.util.UUID;

@Service
public class IdentityService {
    private static final Duration SESSION_LIFETIME = Duration.ofDays(30);

    private final AppUserRepository userRepository;
    private final AuthSessionRepository sessionRepository;
    private final PasswordEncoder passwordEncoder;
    private final AccessTokenService accessTokenService;

    public IdentityService(
            AppUserRepository userRepository,
            AuthSessionRepository sessionRepository,
            PasswordEncoder passwordEncoder,
            AccessTokenService accessTokenService) {
        this.userRepository = userRepository;
        this.sessionRepository = sessionRepository;
        this.passwordEncoder = passwordEncoder;
        this.accessTokenService = accessTokenService;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        String email = normalizeEmail(request.email());
        if (userRepository.existsByEmail(email)) {
            throw new IdentityException(HttpStatus.CONFLICT, "Bu e-posta adresi zaten kayıtlı.");
        }
        if (request.password().getBytes(StandardCharsets.UTF_8).length > 72) {
            throw new IdentityException(HttpStatus.BAD_REQUEST,
                    "Şifre UTF-8 biçiminde en fazla 72 bayt olmalıdır.");
        }
        AppUser user = userRepository.saveAndFlush(new AppUser(
                email, request.name().trim(), passwordEncoder.encode(request.password())));
        return createSession(user);
    }

    @Transactional
    public AuthResponse login(LoginRequest request) {
        if (request.password().getBytes(StandardCharsets.UTF_8).length > 72) {
            throw invalidCredentials();
        }
        String email = normalizeEmail(request.email());
        AppUser user = userRepository.findByEmail(email)
                .orElseThrow(IdentityService::invalidCredentials);
        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw invalidCredentials();
        }
        return createSession(user);
    }

    @Transactional(readOnly = true)
    public UserProfileResponse profile(UUID userId) {
        AppUser user = userRepository.findById(userId)
                .orElseThrow(() -> new IdentityException(HttpStatus.NOT_FOUND, "Kullanıcı bulunamadı."));
        return UserProfileResponse.from(user);
    }

    @Transactional
    public void logout(String token) {
        sessionRepository.deleteByTokenHash(accessTokenService.hash(token));
    }

    private AuthResponse createSession(AppUser user) {
        Instant now = Instant.now();
        sessionRepository.deleteExpired(now);
        String token = accessTokenService.createToken();
        sessionRepository.save(new AuthSession(
                user.getId(), accessTokenService.hash(token), now, now.plus(SESSION_LIFETIME)));
        return new AuthResponse(token, UserProfileResponse.from(user));
    }

    private static String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }

    private static IdentityException invalidCredentials() {
        return new IdentityException(HttpStatus.UNAUTHORIZED, "E-posta veya şifre hatalı.");
    }
}
