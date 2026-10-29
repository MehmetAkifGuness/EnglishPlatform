import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:polyglot_mobile/features/auth/data/auth_api.dart';

class _AuthClient extends http.BaseClient {
  http.BaseRequest? lastRequest;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastRequest = request;
    final payload = jsonEncode({
      'accessToken': 'opaque-token',
      'user': {
        'id': 'id-1',
        'name': 'Öğrenci',
        'email': 'student@example.com',
      },
    });
    return http.StreamedResponse(
      Stream.value(Uint8List.fromList(utf8.encode(payload))),
      201,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
  }
}

void main() {
  test('registers against the configured API and parses the returned session', () async {
    final client = _AuthClient();
    final api = AuthApi(baseUrl: 'https://api.example.test/api/v1/', client: client);

    final session = await api.register(
      name: 'Öğrenci',
      email: 'student@example.com',
      password: 'password123',
    );

    expect(client.lastRequest?.url,
        Uri.parse('https://api.example.test/api/v1/auth/register'));
    expect(session.accessToken, 'opaque-token');
    expect(session.user.name, 'Öğrenci');
  });
}
