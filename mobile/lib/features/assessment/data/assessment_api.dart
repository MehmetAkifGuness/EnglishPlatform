import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../../core/network/api_problem.dart';

import 'assessment_models.dart';

class AssessmentApi {
  AssessmentApi({required String baseUrl, http.Client? client})
    : _baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), ''),
      _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  Future<AssessmentSession> start(String accessToken) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/assessments'),
          headers: {'Authorization': 'Bearer $accessToken'},
        )
        .timeout(const Duration(seconds: 10));
    return _parse(response, AssessmentSession.fromJson);
  }

  Future<void> submitAnswer({
    required String accessToken,
    required String sessionId,
    required int questionId,
    required String answer,
  }) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/assessments/$sessionId/answers'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'questionId': questionId, 'answer': answer}),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw AssessmentApiException(_error(response));
  }

  Future<AssessmentResult> complete({
    required String accessToken,
    required String sessionId,
  }) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/assessments/$sessionId/complete'),
          headers: {'Authorization': 'Bearer $accessToken'},
        )
        .timeout(const Duration(seconds: 10));
    return _parse(response, AssessmentResult.fromJson);
  }

  T _parse<T>(http.Response response, T Function(Map<String, dynamic>) parse) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw AssessmentApiException(_error(response));
    }
    try {
      return parse(jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>);
    } on FormatException {
      throw const AssessmentApiException('Sunucudan geçersiz yanıt alındı.');
    } on TypeError {
      throw const AssessmentApiException('Sunucudan geçersiz yanıt alındı.');
    }
  }

  String _error(http.Response response) {
    return ApiProblem.message(
      response,
      fallback: 'İşlem tamamlanamadı. Tekrar dene.',
      unauthorizedFallback: 'Oturumun sona ermiş. Tekrar giriş yap.',
    );
  }
}

class AssessmentApiException implements Exception {
  const AssessmentApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
