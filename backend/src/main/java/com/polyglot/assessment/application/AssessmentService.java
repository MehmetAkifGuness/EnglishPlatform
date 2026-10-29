package com.polyglot.assessment.application;

import com.polyglot.assessment.api.AssessmentAnswerResponse;
import com.polyglot.assessment.api.AssessmentQuestionResponse;
import com.polyglot.assessment.api.AssessmentResultResponse;
import com.polyglot.assessment.api.AssessmentSessionResponse;
import com.polyglot.assessment.api.TopicAssessmentResult;
import com.polyglot.assessment.persistence.AssessmentAnswer;
import com.polyglot.assessment.persistence.AssessmentAnswerRepository;
import com.polyglot.assessment.persistence.AssessmentQuestion;
import com.polyglot.assessment.persistence.AssessmentQuestionRepository;
import com.polyglot.assessment.persistence.AssessmentSession;
import com.polyglot.assessment.persistence.AssessmentSessionQuestion;
import com.polyglot.assessment.persistence.AssessmentSessionQuestionRepository;
import com.polyglot.assessment.persistence.AssessmentSessionRepository;
import com.polyglot.grammar.persistence.GrammarConcept;
import com.polyglot.grammar.persistence.GrammarConceptRepository;
import com.polyglot.learning.application.LearningProgressService;
import com.polyglot.learning.application.TopicAssessmentEvidence;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Service
public class AssessmentService {
    private final AssessmentQuestionRepository questionRepository;
    private final AssessmentSessionRepository sessionRepository;
    private final AssessmentSessionQuestionRepository sessionQuestionRepository;
    private final AssessmentAnswerRepository answerRepository;
    private final GrammarConceptRepository conceptRepository;
    private final LearningProgressService learningProgressService;

    public AssessmentService(
            AssessmentQuestionRepository questionRepository,
            AssessmentSessionRepository sessionRepository,
            AssessmentSessionQuestionRepository sessionQuestionRepository,
            AssessmentAnswerRepository answerRepository,
            GrammarConceptRepository conceptRepository,
            LearningProgressService learningProgressService) {
        this.questionRepository = questionRepository;
        this.sessionRepository = sessionRepository;
        this.sessionQuestionRepository = sessionQuestionRepository;
        this.answerRepository = answerRepository;
        this.conceptRepository = conceptRepository;
        this.learningProgressService = learningProgressService;
    }

    @Transactional
    public AssessmentSessionResponse start(UUID userId) {
        List<AssessmentQuestion> questions = questionRepository.findAllInCurriculumOrder();
        if (questions.isEmpty()) {
            throw new AssessmentException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Seviye testi şu anda kullanılamıyor.");
        }
        AssessmentSession session = sessionRepository.save(
                new AssessmentSession(userId, Instant.now()));
        Map<Long, GrammarConcept> concepts = conceptRepository.findAllById(
                        questions.stream().map(AssessmentQuestion::getConceptId).distinct().toList())
                .stream().collect(Collectors.toMap(GrammarConcept::getId, concept -> concept));
        List<AssessmentQuestionResponse> questionResponses = questions.stream()
                .map(question -> toQuestionResponse(question, concepts.get(question.getConceptId())))
                .toList();
        List<AssessmentSessionQuestion> sessionQuestions = IntStream.range(0, questions.size())
                .mapToObj(index -> new AssessmentSessionQuestion(
                        session.getId(), questions.get(index).getId(), index + 1))
                .toList();
        sessionQuestionRepository.saveAll(sessionQuestions);
        return new AssessmentSessionResponse(session.getId(), questions.size(), questionResponses);
    }

    @Transactional
    public AssessmentAnswerResponse answer(UUID userId, UUID sessionId, Long questionId, String answer) {
        AssessmentSession session = findSession(userId, sessionId);
        if (session.isCompleted()) {
            throw new AssessmentException(HttpStatus.CONFLICT, "Bu test tamamlanmış.");
        }
        if (!sessionQuestionRepository.existsBySessionIdAndQuestionId(sessionId, questionId)) {
            throw new AssessmentException(HttpStatus.BAD_REQUEST, "Soru bu teste ait değil.");
        }
        AssessmentQuestion question = questionRepository.findById(questionId)
                .orElseThrow(() -> new AssessmentException(HttpStatus.NOT_FOUND, "Soru bulunamadı."));
        String selected = answer.trim();
        boolean isOption = question.getOptions().stream()
                .anyMatch(option -> option.equalsIgnoreCase(selected));
        if (!isOption) {
            throw new AssessmentException(HttpStatus.BAD_REQUEST, "Seçeneklerden birini işaretle.");
        }
        var existingAnswer = answerRepository.findBySessionIdAndQuestionId(sessionId, questionId);
        if (existingAnswer.isPresent()) {
            if (existingAnswer.get().getSelectedAnswer().equalsIgnoreCase(selected)) {
                return new AssessmentAnswerResponse(true);
            }
            throw new AssessmentException(HttpStatus.CONFLICT, "Bu sorunun yanıtı zaten kaydedilmiş.");
        }
        boolean correct = question.getCorrectAnswer().equalsIgnoreCase(selected);
        answerRepository.save(new AssessmentAnswer(
                sessionId, questionId, selected, correct, Instant.now()));
        return new AssessmentAnswerResponse(true);
    }

    @Transactional
    public AssessmentResultResponse complete(UUID userId, UUID sessionId) {
        AssessmentSession session = findSession(userId, sessionId);
        List<AssessmentSessionQuestion> sessionQuestions = sessionQuestionRepository
                .findAllBySessionIdOrderByOrderIndexAsc(sessionId);
        List<AssessmentAnswer> answers = answerRepository.findAllBySessionId(sessionId);
        if (answers.size() != sessionQuestions.size()) {
            throw new AssessmentException(HttpStatus.CONFLICT, "Testte yanıtlanmamış sorular var.");
        }

        Map<Long, AssessmentQuestion> questionsById = questionRepository.findAllById(
                        sessionQuestions.stream().map(AssessmentSessionQuestion::getQuestionId).toList())
                .stream().collect(Collectors.toMap(AssessmentQuestion::getId, question -> question));
        Map<Long, AssessmentAnswer> answersByQuestionId = answers.stream()
                .collect(Collectors.toMap(AssessmentAnswer::getQuestionId, answer -> answer));
        Map<Long, TopicScore> topicScores = new HashMap<>();
        for (AssessmentSessionQuestion sessionQuestion : sessionQuestions) {
            AssessmentQuestion question = questionsById.get(sessionQuestion.getQuestionId());
            AssessmentAnswer answer = answersByQuestionId.get(sessionQuestion.getQuestionId());
            TopicScore score = topicScores.computeIfAbsent(question.getConceptId(), ignored -> new TopicScore());
            score.questionCount++;
            if (answer.isCorrect()) score.correctCount++;
        }

        List<GrammarConcept> concepts = conceptRepository.findAllById(topicScores.keySet()).stream()
                .sorted(Comparator.comparingInt(GrammarConcept::getOrderIndex))
                .toList();
        Map<Long, GrammarConcept> conceptsById = concepts.stream()
                .collect(Collectors.toMap(GrammarConcept::getId, concept -> concept));
        List<TopicAssessmentResult> topicResults = topicScores.entrySet().stream()
                .sorted(Comparator.comparingInt(entry -> conceptsById.get(entry.getKey()).getOrderIndex()))
                .map(entry -> {
                    GrammarConcept concept = conceptsById.get(entry.getKey());
                    TopicScore score = entry.getValue();
                    return new TopicAssessmentResult(concept.getCode(), concept.getTitle(),
                            score.correctCount, score.questionCount,
                            Math.min(0.6, score.questionCount / 5.0));
                })
                .toList();

        int correctCount = topicScores.values().stream().mapToInt(score -> score.correctCount).sum();
        int questionCount = sessionQuestions.size();
        String estimatedLevel = correctCount / (double) questionCount >= 0.7 ? "A2" : "A1";
        String recommendedCode = concepts.stream()
                .filter(GrammarConcept::hasLesson)
                .filter(concept -> topicScores.get(concept.getId()).correctCount
                        < topicScores.get(concept.getId()).questionCount)
                .map(GrammarConcept::getCode)
                .findFirst()
                .orElseGet(() -> concepts.stream().filter(GrammarConcept::hasLesson)
                        .map(GrammarConcept::getCode).findFirst().orElse(null));
        double confidence = Math.min(0.8, questionCount / 20.0);
        if (!session.isCompleted()) {
            Instant completedAt = Instant.now();
            session.complete(completedAt, correctCount, questionCount,
                    estimatedLevel, confidence, recommendedCode);
            sessionRepository.save(session);
            Map<Long, TopicAssessmentEvidence> evidence = topicScores.entrySet().stream()
                    .collect(Collectors.toMap(Map.Entry::getKey, entry ->
                            new TopicAssessmentEvidence(entry.getValue().questionCount,
                                    entry.getValue().correctCount)));
            learningProgressService.recordAssessment(userId, evidence, completedAt);
        }
        return new AssessmentResultResponse(session.getId(), estimatedLevel, confidence,
                correctCount, questionCount, recommendedCode, topicResults);
    }

    private AssessmentSession findSession(UUID userId, UUID sessionId) {
        return sessionRepository.findByIdAndUserId(sessionId, userId)
                .orElseThrow(() -> new AssessmentException(HttpStatus.NOT_FOUND, "Test oturumu bulunamadı."));
    }

    private static AssessmentQuestionResponse toQuestionResponse(
            AssessmentQuestion question, GrammarConcept concept) {
        return new AssessmentQuestionResponse(question.getId(), concept.getCode(),
                concept.getTitle(), question.getPrompt(), question.getOptions());
    }

    private static final class TopicScore {
        private int correctCount;
        private int questionCount;
    }
}
