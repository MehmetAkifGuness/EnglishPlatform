import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../../core/network/api_problem.dart';

class AuthUser {
  const AuthUser({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
  );
}

class AuthSession {
  const AuthSession({required this.accessToken, required this.user});

  final String accessToken;
  final AuthUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    accessToken: json['accessToken'] as String,
    user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
  );
}

class AuthApi {
  AuthApi({required String baseUrl, http.Client? client})
    : _baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), ''),
      _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) => _authenticate('register', {
    'name': name.trim(),
    'email': email.trim(),
    'password': password,
  });

  Future<AuthSession> login({required String email, required String password}) =>
      _authenticate('login', {'email': email.trim(), 'password': password});

  Future<AuthUser> fetchProfile(String accessToken) async {
    final response = await _client
        .get(
          Uri.parse('$_baseUrl/profile'),
          headers: {'Authorization': 'Bearer $accessToken'},
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw AuthApiException(_errorMessage(response), statusCode: response.statusCode);
    }
    try {
      return AuthUser.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } on FormatException {
      throw const AuthApiException('Sunucudan geçersiz yanıt alındı.');
    } on TypeError {
      throw const AuthApiException('Sunucudan geçersiz yanıt alındı.');
    }
  }

  Future<void> logout(String accessToken) async {
    final response = await _client
        .delete(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: {'Authorization': 'Bearer $accessToken'},
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 204) {
      throw AuthApiException(_errorMessage(response), statusCode: response.statusCode);
    }
  }

  Future<AuthSession> _authenticate(
    String action,
    Map<String, String> body,
  ) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/auth/$action'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw AuthApiException(_errorMessage(response), statusCode: response.statusCode);
    }
    try {
      return AuthSession.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } on FormatException {
      throw const AuthApiException('Sunucudan geçersiz yanıt alındı.');
    } on TypeError {
      throw const AuthApiException('Sunucudan geçersiz yanıt alındı.');
    }
  }

  String _errorMessage(http.Response response) {
    return ApiProblem.message(
      response,
      fallback: response.statusCode == 409
          ? 'Bu e-posta adresi zaten kayıtlı.'
          : 'İşlem tamamlanamadı. Lütfen tekrar dene.',
      unauthorizedFallback: 'Oturumun sona ermiş. Lütfen tekrar giriş yap.',
    );
  }
}

class AuthApiException implements Exception {
  const AuthApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
