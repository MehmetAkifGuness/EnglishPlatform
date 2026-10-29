package com.polyglot.grammar.api;

import com.polyglot.grammar.application.GrammarConceptService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/grammar-concepts")
public class GrammarConceptController {
    private final GrammarConceptService grammarConceptService;

    public GrammarConceptController(GrammarConceptService grammarConceptService) {
        this.grammarConceptService = grammarConceptService;
    }

    @GetMapping
    public List<GrammarConceptResponse> list() {
        return grammarConceptService.findAll();
    }
}
