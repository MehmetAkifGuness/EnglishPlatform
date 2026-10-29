import 'auth_api.dart';
import 'auth_session_store.dart';

class AuthSessionManager {
  const AuthSessionManager({required this.api, required this.store});

  final AuthApi api;
  final AuthSessionStore store;

  Future<AuthSession?> restore() async {
    final accessToken = await store.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) return null;

    try {
      final user = await api.fetchProfile(accessToken);
      return AuthSession(accessToken: accessToken, user: user);
    } on AuthApiException catch (exception) {
      if (exception.statusCode == 401) {
        await store.clearAccessToken();
        return null;
      }
      rethrow;
    }
  }

  Future<void> save(AuthSession session) =>
      store.writeAccessToken(session.accessToken);

  Future<void> clear() => store.clearAccessToken();
}
