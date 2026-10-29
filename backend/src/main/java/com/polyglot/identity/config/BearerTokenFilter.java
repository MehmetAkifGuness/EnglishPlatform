package com.polyglot.identity.config;

import com.polyglot.identity.application.AccessTokenService;
import com.polyglot.identity.persistence.AuthSessionRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Instant;
import java.util.List;

public class BearerTokenFilter extends OncePerRequestFilter {
    private final AuthSessionRepository sessionRepository;
    private final AccessTokenService accessTokenService;

    public BearerTokenFilter(
            AuthSessionRepository sessionRepository,
            AccessTokenService accessTokenService) {
        this.sessionRepository = sessionRepository;
        this.accessTokenService = accessTokenService;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {
        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            String token = header.substring(7).trim();
            if (!token.isEmpty()) {
                sessionRepository.findByTokenHashAndExpiresAtAfter(
                                accessTokenService.hash(token), Instant.now())
                        .ifPresent(session -> SecurityContextHolder.getContext().setAuthentication(
                                new UsernamePasswordAuthenticationToken(
                                        session.getUserId().toString(), null,
                                        List.of(new SimpleGrantedAuthority("ROLE_USER")))));
            }
        }
        filterChain.doFilter(request, response);
    }
}
