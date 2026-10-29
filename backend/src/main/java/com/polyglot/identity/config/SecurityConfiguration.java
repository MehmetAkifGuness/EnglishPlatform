package com.polyglot.identity.config;

import com.polyglot.common.api.ApiProblem;
import com.polyglot.identity.application.AccessTokenService;
import com.polyglot.identity.persistence.AuthSessionRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.factory.PasswordEncoderFactories;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import java.io.IOException;

@Configuration
public class SecurityConfiguration {
    @Bean
    PasswordEncoder passwordEncoder() {
        return PasswordEncoderFactories.createDelegatingPasswordEncoder();
    }

    @Bean
    SecurityFilterChain securityFilterChain(
            HttpSecurity http,
            AuthSessionRepository sessionRepository,
            AccessTokenService accessTokenService,
            ObjectMapper objectMapper)
            throws Exception {
        AuthenticationEntryPoint authenticationEntryPoint = (request, response, exception) ->
                writeProblem(objectMapper, response, HttpStatus.UNAUTHORIZED,
                        "AUTHENTICATION_REQUIRED", "Authentication is required to access this resource.",
                        request.getRequestURI());
        AccessDeniedHandler accessDeniedHandler = (request, response, exception) ->
                writeProblem(objectMapper, response, HttpStatus.FORBIDDEN,
                        "ACCESS_DENIED", "You do not have permission to access this resource.",
                        request.getRequestURI());
        return http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(Customizer.withDefaults())
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .exceptionHandling(errors -> errors
                        .authenticationEntryPoint(authenticationEntryPoint)
                        .accessDeniedHandler(accessDeniedHandler))
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        .requestMatchers("/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()
                        .requestMatchers("/actuator/health", "/api/v1/auth/register",
                                "/api/v1/auth/login",
                                "/api/v1/grammar-concepts/**").permitAll()
                        .anyRequest().authenticated())
                .addFilterBefore(
                        new BearerTokenFilter(sessionRepository, accessTokenService),
                        UsernamePasswordAuthenticationFilter.class)
                .build();
    }

    private static void writeProblem(
            ObjectMapper objectMapper,
            jakarta.servlet.http.HttpServletResponse response,
            HttpStatus status,
            String code,
            String detail,
            String path) throws IOException {
        response.setStatus(status.value());
        response.setContentType(MediaType.APPLICATION_PROBLEM_JSON_VALUE);
        objectMapper.writeValue(response.getOutputStream(), ApiProblem.create(status, code, detail, path));
    }
}
