package com.polyglot.config;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.media.Content;
import io.swagger.v3.oas.models.media.IntegerSchema;
import io.swagger.v3.oas.models.media.ObjectSchema;
import io.swagger.v3.oas.models.media.Schema;
import io.swagger.v3.oas.models.media.StringSchema;
import io.swagger.v3.oas.models.responses.ApiResponse;
import io.swagger.v3.oas.models.responses.ApiResponses;
import org.springdoc.core.customizers.OpenApiCustomizer;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Bean;

@Configuration
@OpenAPIDefinition(info = @Info(
        title = "Polyglot API",
        version = "v1",
        description = "REST API for Polyglot English learning."))
@SecurityScheme(
        name = "bearerAuth",
        type = SecuritySchemeType.HTTP,
        scheme = "bearer",
        bearerFormat = "opaque")
public class OpenApiConfiguration {
    @Bean
    OpenApiCustomizer problemDetailsResponses() {
        return openApi -> {
            addProblemSchema(openApi);
            openApi.getPaths().values().forEach(path -> path.readOperations().forEach(operation -> {
                addProblemResponse(operation, "400", "Invalid request.");
                if (operation.getSecurity() != null && !operation.getSecurity().isEmpty()) {
                    addProblemResponse(operation, "401", "Authentication is required.");
                }
                addProblemResponse(operation, "404", "The requested resource was not found.");
                addProblemResponse(operation, "409", "The request conflicts with existing data.");
                addProblemResponse(operation, "500", "Unexpected server error.");
            }));
        };
    }

    private static void addProblemSchema(OpenAPI openApi) {
        if (openApi.getComponents() == null) openApi.setComponents(new Components());
        Schema<?> schema = new ObjectSchema()
                .description("RFC 9457 Problem Details with a stable Polyglot error code.")
                .addProperty("type", new StringSchema().format("uri"))
                .addProperty("title", new StringSchema())
                .addProperty("status", new IntegerSchema())
                .addProperty("detail", new StringSchema())
                .addProperty("instance", new StringSchema().format("uri"))
                .addProperty("code", new StringSchema());
        openApi.getComponents().addSchemas("PolyglotProblem", schema);
    }

    private static void addProblemResponse(
            io.swagger.v3.oas.models.Operation operation, String status, String description) {
        if (operation.getResponses() == null) operation.setResponses(new ApiResponses());
        Schema<?> schema = new Schema<>().$ref("#/components/schemas/PolyglotProblem");
        ApiResponse response = new ApiResponse()
                .description(description)
                .content(new Content().addMediaType("application/problem+json",
                        new io.swagger.v3.oas.models.media.MediaType().schema(schema)));
        operation.getResponses().putIfAbsent(status, response);
    }
}
