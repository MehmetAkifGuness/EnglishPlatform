import 'package:flutter/material.dart';

import '../data/assessment_api.dart';
import '../data/assessment_models.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({
    super.key,
    required this.api,
    required this.accessToken,
    required this.onBack,
  });

  final AssessmentApi api;
  final String accessToken;
  final VoidCallback onBack;

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  late Future<AssessmentSession> _sessionFuture;
  int _questionIndex = 0;
  String? _selectedAnswer;
  String? _error;
  bool _submitting = false;
  AssessmentResult? _result;

  @override
  void initState() {
    super.initState();
    _sessionFuture = widget.api.start(widget.accessToken);
  }

  void _retryStart() => setState(() {
        _sessionFuture = widget.api.start(widget.accessToken);
      });

  Future<void> _submit(AssessmentSession session) async {
    final answer = _selectedAnswer;
    if (answer == null || _submitting) return;
    final question = session.questions[_questionIndex];
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.api.submitAnswer(
        accessToken: widget.accessToken,
        sessionId: session.id,
        questionId: question.id,
        answer: answer,
      );
      if (_questionIndex == session.questions.length - 1) {
        final result = await widget.api.complete(
          accessToken: widget.accessToken,
          sessionId: session.id,
        );
        if (mounted) setState(() => _result = result);
      } else if (mounted) {
        setState(() {
          _questionIndex++;
          _selectedAnswer = null;
        });
      }
    } on AssessmentApiException catch (exception) {
      if (mounted) setState(() => _error = exception.message);
    } on Exception {
      if (mounted) setState(() => _error = 'Yanıt kaydedilemedi. Tekrar dene.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Ana sayfaya dön',
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Seviye belirleme'),
      ),
      body: _result != null
          ? _AssessmentResultView(result: _result!, onBack: widget.onBack)
          : FutureBuilder<AssessmentSession>(
              future: _sessionFuture,
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
                          const Text('Seviye testi başlatılamadı.'),
                          const SizedBox(height: 12),
                          FilledButton.tonal(
                            onPressed: _retryStart,
                            child: const Text('Tekrar dene'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return _QuestionView(
                  session: snapshot.data!,
                  index: _questionIndex,
                  selectedAnswer: _selectedAnswer,
                  error: _error,
                  submitting: _submitting,
                  onSelect: (answer) => setState(() {
                    _selectedAnswer = answer;
                    _error = null;
                  }),
                  onSubmit: () => _submit(snapshot.data!),
                );
              },
            ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.session,
    required this.index,
    required this.selectedAnswer,
    required this.error,
    required this.submitting,
    required this.onSelect,
    required this.onSubmit,
  });

  final AssessmentSession session;
  final int index;
  final String? selectedAnswer;
  final String? error;
  final bool submitting;
  final ValueChanged<String> onSelect;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final question = session.questions[index];
    final isLast = index == session.questions.length - 1;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: (index + 1) / session.questionCount,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Text('${index + 1} / ${session.questionCount}',
                style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 24),
        Chip(
          avatar: const Icon(Icons.menu_book_rounded, size: 18),
          label: Text(question.conceptTitle),
          backgroundColor: colors.primaryContainer,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(height: 12),
        Text(question.prompt,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                )),
        const SizedBox(height: 22),
        ...question.options.map((option) {
          final selected = selectedAnswer == option;
          return Card(
            color: selected ? colors.primaryContainer : Colors.white,
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              enabled: !submitting,
              title: Text(option),
              trailing: Icon(selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded),
              onTap: () => onSelect(option),
            ),
          );
        }),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(error!, style: TextStyle(color: colors.error)),
        ],
        const SizedBox(height: 18),
        FilledButton(
          onPressed: selectedAnswer == null || submitting ? null : onSubmit,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: submitting
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isLast ? 'Sonucu gör' : 'Devam et'),
          ),
        ),
      ],
    );
  }
}

class _AssessmentResultView extends StatelessWidget {
  const _AssessmentResultView({required this.result, required this.onBack});

  final AssessmentResult result;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final matchingRecommendations = result.topics
        .where((topic) => topic.conceptCode == result.recommendedConceptCode);
    final recommended = matchingRecommendations.isEmpty
        ? null
        : matchingRecommendations.first;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
      children: [
        Icon(Icons.auto_awesome_rounded, size: 42, color: colors.primary),
        const SizedBox(height: 14),
        Text('Ön değerlendirme tamamlandı',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Tahmini başlangıç seviyen',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(result.estimatedLevel,
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            )),
        Text('${result.correctCount} doğru / ${result.questionCount} soru',
            textAlign: TextAlign.center),
        const SizedBox(height: 18),
        Card(
          color: colors.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              'Bu sonuç başlangıç tahminidir. Konu başına iki soru kullanıldığı için kesin seviye kararı değildir.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSecondaryContainer),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Konu bazında sonuçlar',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        ...result.topics.map((topic) => _TopicResultTile(topic: topic)),
        if (recommended != null) ...[
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              leading: const Icon(Icons.route_rounded),
              title: const Text('Başlangıç için önerilen konu'),
              subtitle: Text(recommended.conceptTitle),
            ),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton(onPressed: onBack, child: const Text('Öğrenme yoluna dön')),
      ],
    );
  }
}

class _TopicResultTile extends StatelessWidget {
  const _TopicResultTile({required this.topic});

  final TopicAssessmentResult topic;

  @override
  Widget build(BuildContext context) {
    final score = topic.correctCount / topic.questionCount;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(topic.conceptTitle)),
              Text('${topic.correctCount}/${topic.questionCount}'),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(value: score, minHeight: 6),
          const SizedBox(height: 3),
          Text(
            'Ön tahmin güveni: ${(topic.confidence * 100).round()}%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
