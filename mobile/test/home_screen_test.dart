import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polyglot_mobile/features/grammar/data/grammar_concept.dart';
import 'package:polyglot_mobile/features/grammar/data/grammar_concept_api.dart';
import 'package:polyglot_mobile/features/grammar/data/grammar_concept_repository.dart';
import 'package:polyglot_mobile/features/grammar/presentation/home_screen.dart';

class _FakeApi extends GrammarConceptApi {
  _FakeApi(this._loader) : super(baseUrl: 'http://localhost');

  final Future<List<GrammarConcept>> Function() _loader;

  @override
  Future<List<GrammarConcept>> fetchConcepts() => _loader();
}

void main() {
  testWidgets('shows concepts loaded from the repository', (tester) async {
    final repository = GrammarConceptRepository(_FakeApi(() async => const [
      GrammarConcept(id: 1, code: 'basics', title: 'Sentence basics',
        description: 'Learn word order.', cefrLevel: 'A1', orderIndex: 1),
    ]));

    await tester.pumpWidget(MaterialApp(home: HomeScreen(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.text('Sentence basics'), findsOneWidget);
  });

  testWidgets('shows a retryable error state', (tester) async {
    var calls = 0;
    final repository = GrammarConceptRepository(_FakeApi(
      () async {
        calls++;
        throw const GrammarConceptApiException('offline');
      },
    ));

    await tester.pumpWidget(MaterialApp(home: HomeScreen(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.text('Öğrenme yolu yüklenemedi'), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);

    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();
    expect(calls, 2);
  });

  testWidgets('shows the empty state when the API returns no concepts', (tester) async {
    final repository = GrammarConceptRepository(_FakeApi(() async => const []));

    await tester.pumpWidget(MaterialApp(home: HomeScreen(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.text('Öğrenme yolun hazırlanıyor'), findsOneWidget);
  });
}
