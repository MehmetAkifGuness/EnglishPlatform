package com.polyglot.grammar.api;

import com.polyglot.grammar.application.GrammarConceptService;
import com.polyglot.config.WebCorsConfiguration;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.context.annotation.Import;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(GrammarConceptController.class)
@AutoConfigureMockMvc(addFilters = false)
@Import(WebCorsConfiguration.class)
class GrammarConceptControllerTest {
    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private GrammarConceptService grammarConceptService;

    @Test
    void returnsGrammarConceptsAsJson() throws Exception {
        when(grammarConceptService.findAll()).thenReturn(List.of(
                new GrammarConceptResponse(1L, "sentence-basics", "Sentence basics",
                        "Learn simple word order.", "A1", 1, true)));

        mockMvc.perform(get("/api/v1/grammar-concepts"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[0].code").value("sentence-basics"))
                .andExpect(jsonPath("$[0].cefrLevel").value("A1"));
    }

    @Test
    void allowsLocalFlutterWebOrigins() throws Exception {
        when(grammarConceptService.findAll()).thenReturn(List.of());

        mockMvc.perform(get("/api/v1/grammar-concepts")
                        .header("Origin", "http://localhost:54321"))
                .andExpect(status().isOk())
                .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers
                        .header().string("Access-Control-Allow-Origin", "http://localhost:54321"));
    }
}
