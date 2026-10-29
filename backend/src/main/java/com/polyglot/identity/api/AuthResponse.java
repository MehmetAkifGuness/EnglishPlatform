package com.polyglot.identity.api;

public record AuthResponse(String accessToken, UserProfileResponse user) {
}
