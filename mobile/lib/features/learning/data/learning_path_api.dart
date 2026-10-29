import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../../core/network/api_problem.dart';

import 'learning_path_models.dart';

class LearningPathApi {
  LearningPathApi({required String baseUrl, http.Client? client})
    : _baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), ''),
      _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  Future<LearningPath> fetchPath(String accessToken) async {
    final response = await _client
        .get(
          Uri.parse('$_baseUrl/learning-path'),
          headers: {'Authorization': 'Bearer $accessToken'},
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw LearningPathApiException(ApiProblem.message(
        response,
        fallback: 'Öğrenme yolu yüklenemedi. Tekrar dene.',
        unauthorizedFallback: 'Oturumun sona ermiş. Tekrar giriş yap.',
      ));
    }
    try {
      return LearningPath.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } on FormatException {
      throw const LearningPathApiException('Sunucudan geçersiz yanıt alındı.');
    } on TypeError {
      throw const LearningPathApiException('Sunucudan geçersiz yanıt alındı.');
    }
  }
}

class LearningPathApiException implements Exception {
  const LearningPathApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
