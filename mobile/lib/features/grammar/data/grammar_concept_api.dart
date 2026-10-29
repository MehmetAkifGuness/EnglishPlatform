import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_problem.dart';
import 'grammar_concept.dart';
import 'grammar_lesson.dart';

class GrammarConceptApi {
  GrammarConceptApi({required String baseUrl, http.Client? client})
    : _baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), ''),
      _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  Future<List<GrammarConcept>> fetchConcepts() async {
    final response = await _client
        .get(Uri.parse('$_baseUrl/grammar-concepts'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw GrammarConceptApiException(ApiProblem.message(
        response,
        fallback: 'Konu listesi yüklenemedi. Tekrar dene.',
        unauthorizedFallback: 'Oturumun sona ermiş. Tekrar giriş yap.',
      ));
    }

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! List<dynamic>) {
        throw const GrammarConceptApiException('The server response was invalid.');
      }
      return decoded
          .map((item) => GrammarConcept.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } on GrammarConceptApiException {
      rethrow;
    } on FormatException {
      throw const GrammarConceptApiException('The server response was invalid.');
    } on TypeError {
      throw const GrammarConceptApiException('The server response was invalid.');
    }
  }

  Future<GrammarLesson> fetchLesson(String conceptCode) async {
    final response = await _client
        .get(Uri.parse('$_baseUrl/grammar-concepts/$conceptCode/lesson'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw GrammarConceptApiException(ApiProblem.message(
        response,
        fallback: 'Ders içeriği yüklenemedi.',
        unauthorizedFallback: 'Oturumun sona ermiş. Tekrar giriş yap.',
      ));
    }
    try {
      return GrammarLesson.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } on FormatException {
      throw const GrammarConceptApiException('Sunucudan geçersiz yanıt alındı.');
    } on TypeError {
      throw const GrammarConceptApiException('Sunucudan geçersiz yanıt alındı.');
    }
  }

  Future<GrammarAnswerResult> submitAnswer({
    required int exerciseId,
    required String answer,
    required String accessToken,
  }) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/exercises/$exerciseId/answers'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({'answer': answer}),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw GrammarConceptApiException(ApiProblem.message(
        response,
        fallback: 'Cevap değerlendirilemedi. Tekrar dene.',
        unauthorizedFallback: 'Oturumun sona ermiş. Tekrar giriş yap.',
      ));
    }
    try {
      return GrammarAnswerResult.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } on FormatException {
      throw const GrammarConceptApiException('Sunucudan geçersiz yanıt alındı.');
    } on TypeError {
      throw const GrammarConceptApiException('Sunucudan geçersiz yanıt alındı.');
    }
  }
}

class GrammarConceptApiException implements Exception {
  const GrammarConceptApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
