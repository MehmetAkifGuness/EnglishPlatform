package com.polyglot.integration;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@Testcontainers
@SpringBootTest
@AutoConfigureMockMvc
class LearningFlowIntegrationTest {
    private static final List<String> A1_CONCEPTS = List.of(
            "sentence-basics", "subject-pronouns", "be-verb", "articles", "present-simple");

    @Container
    private static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:17.11-alpine");

    @DynamicPropertySource
    static void databaseProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
        registry.add("spring.datasource.username", POSTGRES::getUsername);
        registry.add("spring.datasource.password", POSTGRES::getPassword);
    }

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void assessmentPersistsProgressAndCannotBeAccessedByAnotherUser() throws Exception {
        String learnerToken = registerLearner();
        String otherLearnerToken = registerLearner();

        JsonNode assessment = objectMapper.readTree(mockMvc.perform(post("/api/v1/assessments")
                        .header("Authorization", bearer(learnerToken)))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString());
        String sessionId = assessment.path("id").asText();
        JsonNode questions = assessment.path("questions");
        assertThat(questions).isNotEmpty();

        JsonNode firstQuestion = questions.get(0);
        mockMvc.perform(post("/api/v1/assessments/{sessionId}/answers", sessionId)
                        .header("Authorization", bearer(otherLearnerToken))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(answerRequest(firstQuestion)))
                .andExpect(status().isNotFound());

        for (JsonNode question : questions) {
            mockMvc.perform(post("/api/v1/assessments/{sessionId}/answers", sessionId)
                            .header("Authorization", bearer(learnerToken))
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(answerRequest(question)))
                    .andExpect(status().isOk());
        }

        mockMvc.perform(post("/api/v1/assessments/{sessionId}/complete", sessionId)
                        .header("Authorization", bearer(otherLearnerToken)))
                .andExpect(status().isNotFound());

        mockMvc.perform(post("/api/v1/assessments/{sessionId}/complete", sessionId)
                        .header("Authorization", bearer(learnerToken)))
                .andExpect(status().isOk());
        mockMvc.perform(post("/api/v1/assessments/{sessionId}/complete", sessionId)
                        .header("Authorization", bearer(learnerToken)))
                .andExpect(status().isOk());

        JsonNode learningPath = objectMapper.readTree(mockMvc.perform(get("/api/v1/learning-path")
                        .header("Authorization", bearer(learnerToken)))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString());
        String conceptCode = firstQuestion.path("conceptCode").asText();
        int expectedAttempts = 0;
        for (JsonNode question : questions) {
            if (conceptCode.equals(question.path("conceptCode").asText())) expectedAttempts++;
        }
        JsonNode progress = findProgress(learningPath, conceptCode);

        assertThat(progress).isNotNull();
        assertThat(progress.path("attemptedCount").asInt()).isEqualTo(expectedAttempts);
        assertThat(progress.path("correctCount").asInt()).isBetween(0, expectedAttempts);
        assertThat(progress.path("masteryScore").isNumber()).isTrue();
        assertThat(progress.path("confidence").isNumber()).isTrue();

        JsonNode otherLearnerPath = objectMapper.readTree(mockMvc.perform(get("/api/v1/learning-path")
                        .header("Authorization", bearer(otherLearnerToken)))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString());
        assertThat(findProgress(otherLearnerPath, conceptCode).path("attemptedCount").isNull()).isTrue();
    }

    @Test
    void everyA1LessonHasTranslatedExamplesAndPractice() throws Exception {
        for (String code : A1_CONCEPTS) {
            JsonNode lesson = objectMapper.readTree(mockMvc.perform(
                            get("/api/v1/grammar-concepts/{code}/lesson", code))
                    .andExpect(status().isOk())
                    .andReturn().getResponse().getContentAsString());

            assertThat(lesson.path("examples")).hasSize(10);
            assertThat(lesson.path("exercises")).hasSize(5);
            for (JsonNode example : lesson.path("examples")) {
                assertThat(example.path("englishText").asText()).isNotBlank();
                assertThat(example.path("turkishTranslation").asText()).isNotBlank();
            }
        }
    }

    @Test
    void openApiDocumentsRoutesAndBearerAuthentication() throws Exception {
        JsonNode specification = objectMapper.readTree(mockMvc.perform(get("/v3/api-docs"))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString());

        assertThat(specification.path("info").path("title").asText()).isEqualTo("Polyglot API");
        assertThat(specification.path("paths").has("/api/v1/assessments")).isTrue();
        assertThat(specification.path("components").path("securitySchemes").has("bearerAuth")).isTrue();
        assertThat(specification.path("paths").path("/api/v1/assessments")
                .path("post").path("security").get(0).has("bearerAuth")).isTrue();
        assertThat(specification.path("paths").path("/api/v1/assessments")
                .path("post").path("responses").path("401").path("content")
                .path("application/problem+json").path("schema").path("$ref").asText())
                .isEqualTo("#/components/schemas/PolyglotProblem");
        assertThat(specification.path("components").path("schemas").path("PolyglotProblem")
                .path("properties").has("code")).isTrue();
        assertThat(specification.path("paths").path("/api/v1/auth/register")
                .path("post").has("security")).isFalse();
        assertThat(specification.path("paths").path("/api/v1/auth/register")
                .path("post").path("responses").has("401")).isFalse();
    }

    @Test
    void validationAndAuthenticationErrorsUseProblemDetails() throws Exception {
        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_PROBLEM_JSON))
                .andExpect(jsonPath("$.status").value(400))
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.instance").value("/api/v1/auth/register"));

        mockMvc.perform(get("/api/v1/learning-path"))
                .andExpect(status().isUnauthorized())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_PROBLEM_JSON))
                .andExpect(jsonPath("$.status").value(401))
                .andExpect(jsonPath("$.code").value("AUTHENTICATION_REQUIRED"));

        mockMvc.perform(get("/api/v1/grammar-concepts/unknown-topic/lesson"))
                .andExpect(status().isNotFound())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_PROBLEM_JSON))
                .andExpect(jsonPath("$.code").value("RESOURCE_NOT_FOUND"));
    }

    private String registerLearner() throws Exception {
        String request = objectMapper.createObjectNode()
                .put("name", "Integration Learner")
                .put("email", UUID.randomUUID() + "@example.test")
                .put("password", "Strong-pass-123")
                .toString();
        JsonNode response = objectMapper.readTree(mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(request))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString());
        return response.path("accessToken").asText();
    }

    private String answerRequest(JsonNode question) {
        return objectMapper.createObjectNode()
                .put("questionId", question.path("id").asLong())
                .put("answer", question.path("options").get(0).asText())
                .toString();
    }

    private static JsonNode findProgress(JsonNode learningPath, String conceptCode) {
        for (JsonNode item : learningPath.path("items")) {
            if (conceptCode.equals(item.path("code").asText())) return item;
        }
        return null;
    }

    private static String bearer(String token) {
        return "Bearer " + token;
    }
}
