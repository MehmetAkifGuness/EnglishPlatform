class GrammarConcept {
  const GrammarConcept({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.cefrLevel,
    required this.orderIndex,
    this.hasLesson = false,
  });

  final int id;
  final String code;
  final String title;
  final String description;
  final String cefrLevel;
  final int orderIndex;
  final bool hasLesson;

  factory GrammarConcept.fromJson(Map<String, dynamic> json) {
    return GrammarConcept(
      id: json['id'] as int,
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      cefrLevel: json['cefrLevel'] as String,
      orderIndex: json['orderIndex'] as int,
      hasLesson: json['hasLesson'] as bool? ?? false,
    );
  }
}
