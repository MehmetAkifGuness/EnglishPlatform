package com.polyglot.grammar.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "grammar_lessons")
public class GrammarLesson {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "concept_id", nullable = false, unique = true)
    private GrammarConcept concept;

    @Column(nullable = false, columnDefinition = "text")
    private String explanation;

    protected GrammarLesson() {
    }

    public Long getId() {
        return id;
    }

    public GrammarConcept getConcept() {
        return concept;
    }

    public String getExplanation() {
        return explanation;
    }
}
