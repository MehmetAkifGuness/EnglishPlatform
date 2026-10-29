import 'package:flutter/material.dart';

import '../data/grammar_concept.dart';
import '../data/grammar_concept_api.dart';
import '../data/grammar_lesson.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.api,
    required this.concept,
    required this.accessToken,
    required this.onBack,
  });

  final GrammarConceptApi api;
  final GrammarConcept concept;
  final String accessToken;
  final VoidCallback onBack;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late Future<GrammarLesson> _lesson;

  @override
  void initState() {
    super.initState();
    _lesson = widget.api.fetchLesson(widget.concept.code);
  }

  void _retry() => setState(() {
        _lesson = widget.api.fetchLesson(widget.concept.code);
      });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Öğrenme yoluna dön',
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(widget.concept.title),
      ),
      body: FutureBuilder<GrammarLesson>(
        future: _lesson,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 36),
                    const SizedBox(height: 12),
                    const Text('Ders yüklenemedi. Bağlantını kontrol edip tekrar dene.'),
                    const SizedBox(height: 12),
                    FilledButton.tonal(onPressed: _retry, child: const Text('Tekrar dene')),
                  ],
                ),
              ),
            );
          }
          final lesson = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              Row(
                children: [
                  _LevelChip(level: widget.concept.cefrLevel),
                  const SizedBox(width: 8),
                  Text('DERS ${widget.concept.orderIndex}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          )),
                ],
              ),
              const SizedBox(height: 18),
              Text('Konu anlatımı',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      )),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(lesson.explanation,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55)),
                ),
              ),
              if (lesson.prerequisites.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text('Ön koşul konular',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: lesson.prerequisites
                      .map((title) => Chip(label: Text(title)))
                      .toList(growable: false),
                ),
              ],
              const SizedBox(height: 22),
              Text('Örnek cümleler',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      )),
              const SizedBox(height: 10),
              ...lesson.examples.map((example) => _ExampleCard(example: example)),
              const SizedBox(height: 22),
              Text('Kendini dene',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      )),
              const SizedBox(height: 10),
              if (lesson.exercises.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('Bu konu için alıştırmalar yakında eklenecek.'),
                  ),
                )
              else
                ...lesson.exercises.map((exercise) => _ExerciseCard(
                      key: ValueKey(exercise.id),
                      api: widget.api,
                      exercise: exercise,
                      accessToken: widget.accessToken,
                    )),
            ],
          );
        },
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) => Chip(
        label: Text(level),
        visualDensity: VisualDensity.compact,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      );
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.example});

  final GrammarExample example;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(example.englishText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
              const SizedBox(height: 5),
              Text(example.turkishTranslation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      )),
            ],
          ),
        ),
      );
}

class _ExerciseCard extends StatefulWidget {
  const _ExerciseCard({
    super.key,
    required this.api,
    required this.exercise,
    required this.accessToken,
  });

  final GrammarConceptApi api;
  final GrammarExercise exercise;
  final String accessToken;

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  String? _selected;
  GrammarAnswerResult? _result;
  String? _error;
  bool _submitting = false;

  Future<void> _checkAnswer() async {
    final answer = _selected;
    if (answer == null || _submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await widget.api.submitAnswer(
        exerciseId: widget.exercise.id,
        answer: answer,
        accessToken: widget.accessToken,
      );
      if (mounted) setState(() => _result = result);
    } on GrammarConceptApiException catch (exception) {
      if (mounted) setState(() => _error = exception.message);
    } on Exception {
      if (mounted) setState(() => _error = 'Cevap gönderilemedi. Tekrar dene.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.exercise.prompt,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
            const SizedBox(height: 10),
            ...widget.exercise.options.map((option) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: _selected == option
                        ? colors.primaryContainer
                        : colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      selected: _selected == option,
                      enabled: _result == null && !_submitting,
                      title: Text(option),
                      trailing: Icon(_selected == option
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded),
                      onTap: () => setState(() => _selected = option),
                    ),
                  ),
                )),
            if (_error != null) ...[
              const SizedBox(height: 6),
              Text(_error!, style: TextStyle(color: colors.error)),
            ],
            if (_result case final result?) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: result.correct
                      ? colors.primaryContainer
                      : colors.errorContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.correct ? 'Doğru cevap!' : 'Doğru cevap: ${result.correctAnswer}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: result.correct
                              ? colors.onPrimaryContainer
                              : colors.onErrorContainer,
                        )),
                    const SizedBox(height: 5),
                    Text(result.explanation),
                    TextButton(
                      onPressed: () => setState(() {
                        _result = null;
                        _selected = null;
                      }),
                      child: const Text('Tekrar çöz'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _selected == null || _submitting ? null : _checkAnswer,
                child: _submitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Cevabı kontrol et'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
