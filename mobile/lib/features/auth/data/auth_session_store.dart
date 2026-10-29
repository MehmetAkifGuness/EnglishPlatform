import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class AuthSessionStore {
  Future<String?> readAccessToken();

  Future<void> writeAccessToken(String accessToken);

  Future<void> clearAccessToken();
}

class SecureAuthSessionStore implements AuthSessionStore {
  SecureAuthSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'polyglot.access_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<void> writeAccessToken(String accessToken) =>
      _storage.write(key: _accessTokenKey, value: accessToken);

  @override
  Future<void> clearAccessToken() => _storage.delete(key: _accessTokenKey);
}
