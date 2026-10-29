import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiProblem {
  static String message(
    http.Response response, {
    required String fallback,
    required String unauthorizedFallback,
  }) {
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map<String, dynamic>) {
        final detail = body['detail'] ?? body['message'];
        if (detail is String && detail.isNotEmpty) return detail;
      }
    } on FormatException {
      // Some security and proxy responses have no JSON body.
    }
    return response.statusCode == 401 ? unauthorizedFallback : fallback;
  }
}
