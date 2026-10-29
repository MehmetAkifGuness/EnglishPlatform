package com.polyglot.grammar.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.List;

@Entity
@Table(name = "grammar_exercises")
public class GrammarExercise {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "concept_id", nullable = false)
    private Long conceptId;

    @Column(name = "exercise_type", nullable = false, length = 32)
    private String type;

    @Column(nullable = false, length = 500)
    private String prompt;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "options_json", nullable = false, columnDefinition = "jsonb")
    private List<String> options;

    @Column(name = "correct_answer", nullable = false, length = 300)
    private String correctAnswer;

    @Column(nullable = false, columnDefinition = "text")
    private String explanation;

    @Column(name = "order_index", nullable = false)
    private int orderIndex;

    protected GrammarExercise() {
    }

    public Long getId() {
        return id;
    }

    public Long getConceptId() {
        return conceptId;
    }

    public String getType() {
        return type;
    }

    public String getPrompt() {
        return prompt;
    }

    public List<String> getOptions() {
        return options;
    }

    public String getCorrectAnswer() {
        return correctAnswer;
    }

    public String getExplanation() {
        return explanation;
    }
}
