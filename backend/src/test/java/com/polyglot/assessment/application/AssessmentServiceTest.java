package com.polyglot.assessment.application;

import com.polyglot.assessment.persistence.AssessmentAnswerRepository;
import com.polyglot.assessment.persistence.AssessmentQuestion;
import com.polyglot.assessment.persistence.AssessmentQuestionRepository;
import com.polyglot.assessment.persistence.AssessmentSession;
import com.polyglot.assessment.persistence.AssessmentSessionQuestionRepository;
import com.polyglot.assessment.persistence.AssessmentSessionRepository;
import com.polyglot.grammar.persistence.GrammarConcept;
import com.polyglot.grammar.persistence.GrammarConceptRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyIterable;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AssessmentServiceTest {
    @Mock
    private AssessmentQuestionRepository questionRepository;
    @Mock
    private AssessmentSessionRepository sessionRepository;
    @Mock
    private AssessmentSessionQuestionRepository sessionQuestionRepository;
    @Mock
    private AssessmentAnswerRepository answerRepository;
    @Mock
    private GrammarConceptRepository conceptRepository;
    @InjectMocks
    private AssessmentService assessmentService;

    @Test
    void startsUserSessionWithoutReturningCorrectAnswers() {
        UUID userId = UUID.randomUUID();
        AssessmentQuestion question = mock(AssessmentQuestion.class);
        GrammarConcept concept = mock(GrammarConcept.class);
        when(question.getId()).thenReturn(1L);
        when(question.getConceptId()).thenReturn(9L);
        when(question.getPrompt()).thenReturn("Choose the correct sentence.");
        when(question.getOptions()).thenReturn(List.of("I read books.", "Read I books."));
        when(concept.getId()).thenReturn(9L);
        when(concept.getCode()).thenReturn("sentence-basics");
        when(concept.getTitle()).thenReturn("Temel cümle yapısı");
        when(questionRepository.findAllInCurriculumOrder()).thenReturn(List.of(question));
        when(conceptRepository.findAllById(anyIterable())).thenReturn(List.of(concept));
        when(sessionRepository.save(any(AssessmentSession.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        var response = assessmentService.start(userId);

        assertThat(response.questionCount()).isEqualTo(1);
        assertThat(response.questions()).hasSize(1);
        assertThat(response.questions().getFirst().options())
                .containsExactly("I read books.", "Read I books.");
        ArgumentCaptor<List<com.polyglot.assessment.persistence.AssessmentSessionQuestion>> captor =
                ArgumentCaptor.forClass(List.class);
        verify(sessionQuestionRepository).saveAll(captor.capture());
        assertThat(captor.getValue()).hasSize(1);
    }
}
