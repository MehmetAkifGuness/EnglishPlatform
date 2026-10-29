package com.polyglot.grammar.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "grammar_concepts")
public class GrammarConcept {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 80)
    private String code;

    @Column(nullable = false, length = 160)
    private String title;

    @Column(nullable = false, length = 1000)
    private String description;

    @Column(name = "cefr_level", nullable = false, length = 2)
    private String cefrLevel;

    @Column(name = "order_index", nullable = false)
    private int orderIndex;

    @Column(name = "has_lesson", nullable = false)
    private boolean hasLesson;

    protected GrammarConcept() {
    }

    public Long getId() {
        return id;
    }

    public String getCode() {
        return code;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public String getCefrLevel() {
        return cefrLevel;
    }

    public int getOrderIndex() {
        return orderIndex;
    }

    public boolean hasLesson() {
        return hasLesson;
    }
}
