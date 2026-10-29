package com.polyglot.grammar.application;

import com.polyglot.grammar.api.GrammarConceptResponse;
import com.polyglot.grammar.persistence.GrammarConceptRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class GrammarConceptService {
    private final GrammarConceptRepository grammarConceptRepository;

    public GrammarConceptService(GrammarConceptRepository grammarConceptRepository) {
        this.grammarConceptRepository = grammarConceptRepository;
    }

    @Transactional(readOnly = true)
    public List<GrammarConceptResponse> findAll() {
        return grammarConceptRepository.findAllByOrderByOrderIndexAsc().stream()
                .map(concept -> new GrammarConceptResponse(
                        concept.getId(), concept.getCode(), concept.getTitle(),
                        concept.getDescription(), concept.getCefrLevel(), concept.getOrderIndex(),
                        concept.hasLesson()))
                .toList();
    }
}
