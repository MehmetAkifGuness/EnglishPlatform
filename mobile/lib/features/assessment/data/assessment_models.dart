class AssessmentSession {
  const AssessmentSession({
    required this.id,
    required this.questionCount,
    required this.questions,
  });

  final String id;
  final int questionCount;
  final List<AssessmentQuestion> questions;

  factory AssessmentSession.fromJson(Map<String, dynamic> json) => AssessmentSession(
    id: json['id'] as String,
    questionCount: json['questionCount'] as int,
    questions: (json['questions'] as List<dynamic>)
        .map((item) => AssessmentQuestion.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
  );
}

class AssessmentQuestion {
  const AssessmentQuestion({
    required this.id,
    required this.conceptCode,
    required this.conceptTitle,
    required this.prompt,
    required this.options,
  });

  final int id;
  final String conceptCode;
  final String conceptTitle;
  final String prompt;
  final List<String> options;

  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) => AssessmentQuestion(
    id: json['id'] as int,
    conceptCode: json['conceptCode'] as String,
    conceptTitle: json['conceptTitle'] as String,
    prompt: json['prompt'] as String,
    options: (json['options'] as List<dynamic>).cast<String>(),
  );
}

class AssessmentResult {
  const AssessmentResult({
    required this.sessionId,
    required this.estimatedLevel,
    required this.confidence,
    required this.correctCount,
    required this.questionCount,
    required this.recommendedConceptCode,
    required this.topics,
  });

  final String sessionId;
  final String estimatedLevel;
  final double confidence;
  final int correctCount;
  final int questionCount;
  final String? recommendedConceptCode;
  final List<TopicAssessmentResult> topics;

  factory AssessmentResult.fromJson(Map<String, dynamic> json) => AssessmentResult(
    sessionId: json['sessionId'] as String,
    estimatedLevel: json['estimatedLevel'] as String,
    confidence: (json['confidence'] as num).toDouble(),
    correctCount: json['correctCount'] as int,
    questionCount: json['questionCount'] as int,
    recommendedConceptCode: json['recommendedConceptCode'] as String?,
    topics: (json['topics'] as List<dynamic>)
        .map((item) => TopicAssessmentResult.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
  );
}

class TopicAssessmentResult {
  const TopicAssessmentResult({
    required this.conceptCode,
    required this.conceptTitle,
    required this.correctCount,
    required this.questionCount,
    required this.confidence,
  });

  final String conceptCode;
  final String conceptTitle;
  final int correctCount;
  final int questionCount;
  final double confidence;

  factory TopicAssessmentResult.fromJson(Map<String, dynamic> json) =>
      TopicAssessmentResult(
        conceptCode: json['conceptCode'] as String,
        conceptTitle: json['conceptTitle'] as String,
        correctCount: json['correctCount'] as int,
        questionCount: json['questionCount'] as int,
        confidence: (json['confidence'] as num).toDouble(),
      );
}
