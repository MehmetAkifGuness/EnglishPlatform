package com.polyglot.grammar.application;

import com.polyglot.grammar.persistence.GrammarConcept;
import com.polyglot.grammar.persistence.GrammarConceptRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GrammarConceptServiceTest {
    @Mock
    private GrammarConceptRepository repository;

    @InjectMocks
    private GrammarConceptService service;

    @Test
    void returnsConceptsInRepositoryOrderAsApiResponses() {
        GrammarConcept concept = org.mockito.Mockito.mock(GrammarConcept.class);
        when(concept.getId()).thenReturn(1L);
        when(concept.getCode()).thenReturn("sentence-basics");
        when(concept.getTitle()).thenReturn("Sentence basics");
        when(concept.getDescription()).thenReturn("Learn simple word order.");
        when(concept.getCefrLevel()).thenReturn("A1");
        when(concept.getOrderIndex()).thenReturn(1);
        when(concept.hasLesson()).thenReturn(true);
        when(repository.findAllByOrderByOrderIndexAsc()).thenReturn(List.of(concept));

        var result = service.findAll();

        assertThat(result).containsExactly(new com.polyglot.grammar.api.GrammarConceptResponse(
                1L, "sentence-basics", "Sentence basics", "Learn simple word order.", "A1", 1, true));
        verify(repository).findAllByOrderByOrderIndexAsc();
    }
}
