import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:polyglot_mobile/features/grammar/data/grammar_concept_api.dart';

void main() {
  test('fetches concepts from the configured API and parses the response', () async {
    Uri? requestedUri;
    final client = MockClient((request) async {
      requestedUri = request.url;
      return http.Response.bytes(utf8.encode('[{"id":1,"code":"basics",'
          '"title":"Sentence basics","description":"Word order",'
          '"cefrLevel":"A1","orderIndex":1,"hasLesson":true}]'), 200);
    });
    final api = GrammarConceptApi(
      baseUrl: 'https://example.test/api/v1/',
      client: client,
    );

    final concepts = await api.fetchConcepts();

    expect(requestedUri, Uri.parse('https://example.test/api/v1/grammar-concepts'));
    expect(concepts.single.title, 'Sentence basics');
    expect(concepts.single.cefrLevel, 'A1');
    expect(concepts.single.hasLesson, isTrue);
  });

  test('reports non-success HTTP status as an API error', () async {
    final api = GrammarConceptApi(
      baseUrl: 'https://example.test/api/v1',
      client: MockClient((_) async => http.Response('', 503)),
    );

    await expectLater(api.fetchConcepts(), throwsA(isA<GrammarConceptApiException>()));
  });

  test('reports malformed JSON as an API error', () async {
    final api = GrammarConceptApi(
      baseUrl: 'https://example.test/api/v1',
      client: MockClient((_) async => http.Response('{invalid', 200)),
    );

    await expectLater(api.fetchConcepts(), throwsA(isA<GrammarConceptApiException>()));
  });

  test('loads the lesson without exposing its answer key', () async {
    final client = MockClient((_) async => http.Response.bytes(
          utf8.encode('{"conceptCode":"sentence-basics","title":"Temel cümle yapısı",'
              '"explanation":"Özne + Fiil + Nesne", "prerequisites":[], '
              '"examples":[{"englishText":"I read books.",'
              '"turkishTranslation":"Ben kitap okurum."}], '
              '"exercises":[{"id":1,"type":"MULTIPLE_CHOICE",'
              '"prompt":"Seç.","options":["I read books."]}]}'),
          200,
        ));
    final api = GrammarConceptApi(baseUrl: 'https://example.test/api/v1', client: client);

    final lesson = await api.fetchLesson('sentence-basics');

    expect(lesson.examples.single.englishText, 'I read books.');
    expect(lesson.exercises.single.options, ['I read books.']);
  });

  test('submits an answer with the user session token and parses evaluation', () async {
    Uri? requestedUri;
    String? authorization;
    final client = MockClient((request) async {
      requestedUri = request.url;
      authorization = request.headers['Authorization'];
      return http.Response.bytes(
        utf8.encode('{"correct":true,"correctAnswer":"I drink coffee.",'
            '"explanation":"Özne + Fiil + Nesne."}'),
        200,
      );
    });
    final api = GrammarConceptApi(baseUrl: 'https://example.test/api/v1', client: client);

    final result = await api.submitAnswer(
      exerciseId: 4,
      answer: 'I drink coffee.',
      accessToken: 'session-token',
    );

    expect(requestedUri, Uri.parse('https://example.test/api/v1/exercises/4/answers'));
    expect(authorization, 'Bearer session-token');
    expect(result.correct, isTrue);
  });
}
