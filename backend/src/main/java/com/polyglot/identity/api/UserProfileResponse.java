package com.polyglot.identity.api;

import com.polyglot.identity.persistence.AppUser;

import java.util.UUID;

public record UserProfileResponse(UUID id, String name, String email) {
    public static UserProfileResponse from(AppUser user) {
        return new UserProfileResponse(user.getId(), user.getDisplayName(), user.getEmail());
    }
}
