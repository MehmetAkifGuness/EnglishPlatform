import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:polyglot_mobile/features/grammar/data/grammar_concept.dart';
import 'package:polyglot_mobile/features/grammar/data/grammar_concept_api.dart';
import 'package:polyglot_mobile/features/grammar/presentation/lesson_screen.dart';

void main() {
  testWidgets('loads a lesson and shows the evaluated answer explanation', (tester) async {
    final client = MockClient((request) async {
      if (request.method == 'GET') {
        return http.Response.bytes(
          utf8.encode('{"conceptCode":"sentence-basics",'
              '"title":"Temel cümle yapısı",'
              '"explanation":"İngilizcede temel sıra Özne + Fiil + Nesnedir.",'
              '"prerequisites":[],"examples":[{"englishText":"I read books.",'
              '"turkishTranslation":"Ben kitap okurum."}],'
              '"exercises":[{"id":7,"type":"MULTIPLE_CHOICE",'
              '"prompt":"Doğru cümleyi seç.",'
              '"options":["I drink coffee.","Drink I coffee."]}]}'),
          200,
        );
      }
      return http.Response.bytes(
        utf8.encode('{"correct":true,"correctAnswer":"I drink coffee.",'
            '"explanation":"Özne + Fiil + Nesne."}'),
        200,
      );
    });
    final api = GrammarConceptApi(baseUrl: 'https://example.test/api/v1', client: client);

    await tester.pumpWidget(MaterialApp(
      home: LessonScreen(
        api: api,
        concept: const GrammarConcept(
          id: 1,
          code: 'sentence-basics',
          title: 'Temel cümle yapısı',
          description: 'İngilizce cümle sıralaması.',
          cefrLevel: 'A1',
          orderIndex: 1,
          hasLesson: true,
        ),
        accessToken: 'session-token',
        onBack: () {},
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Ben kitap okurum.'), findsOneWidget);
    await tester.tap(find.text('I drink coffee.'));
    await tester.ensureVisible(find.text('Cevabı kontrol et'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cevabı kontrol et'));
    await tester.pumpAndSettle();

    expect(find.text('Doğru cevap!'), findsOneWidget);
    expect(find.text('Özne + Fiil + Nesne.'), findsOneWidget);
  });
}
