import '../../grammar/data/grammar_concept.dart';

class LearningPath {
  const LearningPath({required this.recommendedConceptCode, required this.items});

  final String? recommendedConceptCode;
  final List<LearningPathItem> items;

  factory LearningPath.fromJson(Map<String, dynamic> json) => LearningPath(
    recommendedConceptCode: json['recommendedConceptCode'] as String?,
    items: (json['items'] as List<dynamic>)
        .map((item) => LearningPathItem.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
  );
}

class LearningPathItem {
  const LearningPathItem({
    required this.code,
    required this.title,
    required this.description,
    required this.cefrLevel,
    required this.orderIndex,
    required this.hasLesson,
    this.attemptedCount,
    this.correctCount,
    this.masteryScore,
    this.confidence,
    this.nextReviewAt,
    this.status = 'YENİ',
    this.recommended = false,
  });

  final String code;
  final String title;
  final String description;
  final String cefrLevel;
  final int orderIndex;
  final bool hasLesson;
  final int? attemptedCount;
  final int? correctCount;
  final double? masteryScore;
  final double? confidence;
  final DateTime? nextReviewAt;
  final String status;
  final bool recommended;

  factory LearningPathItem.fromJson(Map<String, dynamic> json) => LearningPathItem(
    code: json['code'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    cefrLevel: json['cefrLevel'] as String,
    orderIndex: json['orderIndex'] as int,
    hasLesson: json['hasLesson'] as bool,
    attemptedCount: json['attemptedCount'] as int?,
    correctCount: json['correctCount'] as int?,
    masteryScore: (json['masteryScore'] as num?)?.toDouble(),
    confidence: (json['confidence'] as num?)?.toDouble(),
    nextReviewAt: json['nextReviewAt'] == null
        ? null
        : DateTime.parse(json['nextReviewAt'] as String),
    status: json['status'] as String? ?? 'YENİ',
    recommended: json['recommended'] as bool? ?? false,
  );

  factory LearningPathItem.fromConcept(GrammarConcept concept) => LearningPathItem(
    code: concept.code,
    title: concept.title,
    description: concept.description,
    cefrLevel: concept.cefrLevel,
    orderIndex: concept.orderIndex,
    hasLesson: concept.hasLesson,
  );

  GrammarConcept toGrammarConcept() => GrammarConcept(
    id: orderIndex,
    code: code,
    title: title,
    description: description,
    cefrLevel: cefrLevel,
    orderIndex: orderIndex,
    hasLesson: hasLesson,
  );
}
