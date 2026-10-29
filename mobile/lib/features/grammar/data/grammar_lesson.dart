class GrammarLesson {
  const GrammarLesson({
    required this.conceptCode,
    required this.title,
    required this.explanation,
    required this.prerequisites,
    required this.examples,
    required this.exercises,
  });

  final String conceptCode;
  final String title;
  final String explanation;
  final List<String> prerequisites;
  final List<GrammarExample> examples;
  final List<GrammarExercise> exercises;

  factory GrammarLesson.fromJson(Map<String, dynamic> json) => GrammarLesson(
    conceptCode: json['conceptCode'] as String,
    title: json['title'] as String,
    explanation: json['explanation'] as String,
    prerequisites: (json['prerequisites'] as List<dynamic>).cast<String>(),
    examples: (json['examples'] as List<dynamic>)
        .map((item) => GrammarExample.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
    exercises: (json['exercises'] as List<dynamic>)
        .map((item) => GrammarExercise.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
  );
}

class GrammarExample {
  const GrammarExample({required this.englishText, required this.turkishTranslation});

  final String englishText;
  final String turkishTranslation;

  factory GrammarExample.fromJson(Map<String, dynamic> json) => GrammarExample(
    englishText: json['englishText'] as String,
    turkishTranslation: json['turkishTranslation'] as String,
  );
}

class GrammarExercise {
  const GrammarExercise({
    required this.id,
    required this.type,
    required this.prompt,
    required this.options,
  });

  final int id;
  final String type;
  final String prompt;
  final List<String> options;

  factory GrammarExercise.fromJson(Map<String, dynamic> json) => GrammarExercise(
    id: json['id'] as int,
    type: json['type'] as String,
    prompt: json['prompt'] as String,
    options: (json['options'] as List<dynamic>).cast<String>(),
  );
}

class GrammarAnswerResult {
  const GrammarAnswerResult({
    required this.correct,
    required this.correctAnswer,
    required this.explanation,
  });

  final bool correct;
  final String correctAnswer;
  final String explanation;

  factory GrammarAnswerResult.fromJson(Map<String, dynamic> json) =>
      GrammarAnswerResult(
        correct: json['correct'] as bool,
        correctAnswer: json['correctAnswer'] as String,
        explanation: json['explanation'] as String,
      );
}
