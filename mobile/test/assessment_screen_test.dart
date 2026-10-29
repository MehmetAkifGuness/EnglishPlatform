import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:polyglot_mobile/features/assessment/data/assessment_api.dart';
import 'package:polyglot_mobile/features/assessment/presentation/assessment_screen.dart';

void main() {
  testWidgets('records answers and displays an estimated level and topic results', (tester) async {
    var recordedAnswers = 0;
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/assessments')) {
        return http.Response.bytes(
          utf8.encode('{"id":"session-1","questionCount":2,"questions":['
              '{"id":1,"conceptCode":"sentence-basics",'
              '"conceptTitle":"Temel cümle yapısı",'
              '"prompt":"Doğru cümleyi seç.",'
              '"options":["The dog eats food.","Eats the dog food."]},'
              '{"id":2,"conceptCode":"subject-pronouns",'
              '"conceptTitle":"Özne zamirleri",'
              '"prompt":"Sara and I ___.",'
              '"options":["We", "They"]}]}'),
          201,
        );
      }
      if (request.url.path.endsWith('/answers')) {
        recordedAnswers++;
        return http.Response('{"recorded":true}', 200);
      }
      return http.Response.bytes(
        utf8.encode('{"sessionId":"session-1","estimatedLevel":"A1",'
            '"confidence":0.8,"correctCount":1,"questionCount":2,'
            '"recommendedConceptCode":"sentence-basics","topics":['
            '{"conceptCode":"sentence-basics","conceptTitle":"Temel cümle yapısı",'
            '"correctCount":1,"questionCount":1,"confidence":0.2},'
            '{"conceptCode":"subject-pronouns","conceptTitle":"Özne zamirleri",'
            '"correctCount":0,"questionCount":1,"confidence":0.2}]}'),
        200,
      );
    });

    await tester.pumpWidget(MaterialApp(
      home: AssessmentScreen(
        api: AssessmentApi(baseUrl: 'https://example.test/api/v1', client: client),
        accessToken: 'session-token',
        onBack: () {},
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Doğru cümleyi seç.'), findsOneWidget);
    await tester.tap(find.text('The dog eats food.'));
    await tester.ensureVisible(find.text('Devam et'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Devam et'));
    await tester.pumpAndSettle();

    expect(find.text('Sara and I ___. '), findsNothing);
    expect(find.text('Sara and I ___.'), findsOneWidget);
    await tester.tap(find.text('We'));
    await tester.ensureVisible(find.text('Sonucu gör'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sonucu gör'));
    await tester.pumpAndSettle();

    expect(recordedAnswers, 2);
    expect(find.text('Ön değerlendirme tamamlandı'), findsOneWidget);
    expect(find.text('A1'), findsOneWidget);
    expect(find.text('Başlangıç için önerilen konu'), findsOneWidget);
  });
}
