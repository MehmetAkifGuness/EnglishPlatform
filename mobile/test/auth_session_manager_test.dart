import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:polyglot_mobile/features/auth/data/auth_api.dart';
import 'package:polyglot_mobile/features/auth/data/auth_session_manager.dart';
import 'package:polyglot_mobile/features/auth/data/auth_session_store.dart';

class _MemorySessionStore implements AuthSessionStore {
  _MemorySessionStore([this.token]);

  String? token;

  @override
  Future<String?> readAccessToken() async => token;

  @override
  Future<void> writeAccessToken(String accessToken) async => token = accessToken;

  @override
  Future<void> clearAccessToken() async => token = null;
}

class _ReplyClient extends http.BaseClient {
  _ReplyClient({required this.statusCode, required this.body});

  final int statusCode;
  final Map<String, Object?> body;
  http.BaseRequest? lastRequest;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastRequest = request;
    return http.StreamedResponse(
      Stream.value(Uint8List.fromList(utf8.encode(jsonEncode(body)))),
      statusCode,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
  }
}

void main() {
  test('restores the user profile from the saved bearer token', () async {
    final store = _MemorySessionStore('saved-token');
    final client = _ReplyClient(
      statusCode: 200,
      body: {'id': 'learner-1', 'name': 'Learner', 'email': 'learner@example.test'},
    );
    final manager = AuthSessionManager(
      api: AuthApi(baseUrl: 'https://api.example.test/api/v1', client: client),
      store: store,
    );

    final session = await manager.restore();

    expect(session?.accessToken, 'saved-token');
    expect(session?.user.name, 'Learner');
    expect(client.lastRequest?.headers['Authorization'], 'Bearer saved-token');
    expect(store.token, 'saved-token');
  });

  test('clears a token rejected by the server', () async {
    final store = _MemorySessionStore('expired-token');
    final manager = AuthSessionManager(
      api: AuthApi(
        baseUrl: 'https://api.example.test/api/v1',
        client: _ReplyClient(
          statusCode: 401,
          body: {
            'type': 'about:blank',
            'title': 'Unauthorized',
            'status': 401,
            'detail': 'Authentication is required.',
            'code': 'AUTHENTICATION_REQUIRED',
          },
        ),
      ),
      store: store,
    );

    expect(await manager.restore(), isNull);
    expect(store.token, isNull);
  });

  test('keeps the token when restoration fails temporarily', () async {
    final store = _MemorySessionStore('saved-token');
    final manager = AuthSessionManager(
      api: AuthApi(
        baseUrl: 'https://api.example.test/api/v1',
        client: _ReplyClient(
          statusCode: 503,
          body: {
            'type': 'about:blank',
            'title': 'Service Unavailable',
            'status': 503,
            'detail': 'Service unavailable.',
            'code': 'INTERNAL_ERROR',
          },
        ),
      ),
      store: store,
    );

    await expectLater(
      manager.restore(),
      throwsA(isA<AuthApiException>().having((error) => error.statusCode, 'statusCode', 503)),
    );
    expect(store.token, 'saved-token');
  });

  test('saves and clears the authenticated token', () async {
    final store = _MemorySessionStore();
    final manager = AuthSessionManager(
      api: AuthApi(baseUrl: 'https://api.example.test/api/v1'),
      store: store,
    );
    const session = AuthSession(
      accessToken: 'new-token',
      user: AuthUser(id: 'learner-1', name: 'Learner', email: 'learner@example.test'),
    );

    await manager.save(session);
    expect(store.token, 'new-token');

    await manager.clear();
    expect(store.token, isNull);
  });
}
