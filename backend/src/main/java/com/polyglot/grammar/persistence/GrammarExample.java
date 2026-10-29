package com.polyglot.grammar.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "grammar_examples")
public class GrammarExample {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "lesson_id", nullable = false)
    private Long lessonId;

    @Column(name = "english_text", nullable = false, length = 500)
    private String englishText;

    @Column(name = "turkish_translation", nullable = false, length = 500)
    private String turkishTranslation;

    @Column(name = "order_index", nullable = false)
    private int orderIndex;

    protected GrammarExample() {
    }

    public String getEnglishText() {
        return englishText;
    }

    public String getTurkishTranslation() {
        return turkishTranslation;
    }
}
