import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:polyglot_mobile/features/learning/data/learning_path_api.dart';

void main() {
  test('fetches a personalized path with the session token', () async {
    Uri? requestedUri;
    String? authorization;
    final api = LearningPathApi(
      baseUrl: 'https://example.test/api/v1/',
      client: MockClient((request) async {
        requestedUri = request.url;
        authorization = request.headers['Authorization'];
        return http.Response.bytes(utf8.encode('''{
          "recommendedConceptCode":"sentence-basics",
          "items":[{"code":"sentence-basics","title":"Sentence basics",
            "description":"Word order","cefrLevel":"A1","orderIndex":1,
            "hasLesson":true,"attemptedCount":2,"correctCount":1,
            "masteryScore":0.5,"confidence":0.25,"nextReviewAt":"2026-10-29T10:00:00Z",
            "status":"GELİŞİYOR","recommended":true}]
        }'''), 200);
      }),
    );

    final path = await api.fetchPath('session-token');

    expect(requestedUri, Uri.parse('https://example.test/api/v1/learning-path'));
    expect(authorization, 'Bearer session-token');
    expect(path.recommendedConceptCode, 'sentence-basics');
    expect(path.items.single.masteryScore, 0.5);
    expect(path.items.single.recommended, isTrue);
    expect(path.items.single.nextReviewAt, DateTime.parse('2026-10-29T10:00:00Z'));
  });

  test('reports expired sessions clearly', () async {
    final api = LearningPathApi(
      baseUrl: 'https://example.test/api/v1',
      client: MockClient((_) async => http.Response('', 401)),
    );

    await expectLater(api.fetchPath('expired'), throwsA(isA<LearningPathApiException>()));
  });
}
