package com.polyglot.identity.application;

import com.polyglot.identity.api.RegisterRequest;
import com.polyglot.identity.persistence.AppUser;
import com.polyglot.identity.persistence.AppUserRepository;
import com.polyglot.identity.persistence.AuthSessionRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class IdentityServiceTest {
    @Mock
    private AppUserRepository userRepository;
    @Mock
    private AuthSessionRepository sessionRepository;
    @Mock
    private PasswordEncoder passwordEncoder;
    @Mock
    private AccessTokenService accessTokenService;
    @InjectMocks
    private IdentityService identityService;

    @Test
    void registrationNormalizesEmailHashesPasswordAndReturnsSessionToken() {
        when(userRepository.existsByEmail("learner@example.com")).thenReturn(false);
        when(passwordEncoder.encode("password123")).thenReturn("{bcrypt}encoded-password");
        when(userRepository.saveAndFlush(any(AppUser.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
        when(accessTokenService.createToken()).thenReturn("opaque-token");
        when(accessTokenService.hash("opaque-token")).thenReturn("stored-token-hash");

        var result = identityService.register(new RegisterRequest(
                " Learner@Example.com ", " Learner ", "password123"));

        ArgumentCaptor<AppUser> userCaptor = ArgumentCaptor.forClass(AppUser.class);
        verify(userRepository).saveAndFlush(userCaptor.capture());
        assertThat(userCaptor.getValue().getEmail()).isEqualTo("learner@example.com");
        assertThat(userCaptor.getValue().getDisplayName()).isEqualTo("Learner");
        assertThat(userCaptor.getValue().getPasswordHash()).isEqualTo("{bcrypt}encoded-password");
        assertThat(result.accessToken()).isEqualTo("opaque-token");
        assertThat(result.user().email()).isEqualTo("learner@example.com");
        verify(sessionRepository).save(any());
    }
}
