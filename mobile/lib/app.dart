import 'package:flutter/material.dart';

import 'features/grammar/data/grammar_concept_api.dart';
import 'features/grammar/data/grammar_concept.dart';
import 'features/grammar/data/grammar_concept_repository.dart';
import 'features/grammar/presentation/lesson_screen.dart';
import 'features/grammar/presentation/home_screen.dart';
import 'features/auth/data/auth_api.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/assessment/data/assessment_api.dart';
import 'features/assessment/presentation/assessment_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/learning/data/learning_path_api.dart';
import 'features/auth/data/auth_session_manager.dart';
import 'features/auth/data/auth_session_store.dart';

class PolyglotApp extends StatefulWidget {
  const PolyglotApp({super.key, this.sessionStore, this.authApi});

  final AuthSessionStore? sessionStore;
  final AuthApi? authApi;

  @override
  State<PolyglotApp> createState() => _PolyglotAppState();
}

class _PolyglotAppState extends State<PolyglotApp> {
  bool _onboardingComplete = false;
  bool _sessionReady = false;
  bool _showProfile = false;
  bool _showAssessment = false;
  String? _sessionRestoreError;
  GrammarConcept? _selectedConcept;
  late final GrammarConceptApi _grammarApi;
  late final AssessmentApi _assessmentApi;
  late final GrammarConceptRepository _grammarRepository;
  late final AuthApi _authApi;
  late final AuthSessionManager _sessionManager;
  late final LearningPathApi _learningPathApi;

  @override
  void initState() {
    super.initState();
    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080/api/v1',
    );
    _grammarApi = GrammarConceptApi(baseUrl: baseUrl);
    _assessmentApi = AssessmentApi(baseUrl: baseUrl);
    _grammarRepository = GrammarConceptRepository(_grammarApi);
    _authApi = widget.authApi ?? AuthApi(baseUrl: baseUrl);
    _sessionManager = AuthSessionManager(
      api: _authApi,
      store: widget.sessionStore ?? SecureAuthSessionStore(),
    );
    _learningPathApi = LearningPathApi(baseUrl: baseUrl);
    _restoreSession();
  }

  AuthSession? _session;

  Future<void> _restoreSession() async {
    try {
      final session = await _sessionManager.restore();
      if (!mounted) return;
      setState(() {
        _session = session;
        _sessionReady = true;
        _sessionRestoreError = null;
        if (session != null) _onboardingComplete = true;
      });
    } on Exception {
      if (!mounted) return;
      setState(() {
        _sessionReady = true;
        _sessionRestoreError = 'Oturum doğrulanamadı. Bağlantını kontrol edip tekrar dene.';
      });
    }
  }

  Future<void> _retrySessionRestore() async {
    setState(() {
      _sessionReady = false;
      _sessionRestoreError = null;
    });
    await _restoreSession();
  }

  Future<void> _startAuthenticatedSession(AuthSession session) async {
    await _sessionManager.save(session);
    if (!mounted) return;
    setState(() {
      _session = session;
      _showProfile = false;
      _sessionRestoreError = null;
    });
  }

  Future<void> _endSession() async {
    try {
      await _sessionManager.clear();
    } finally {
      if (mounted) {
        setState(() {
          _session = null;
          _showProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF28685C);
    return MaterialApp(
      title: 'Polyglot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
          surface: const Color(0xFFF7F8F4),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8F4),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE7EAE4)),
          ),
        ),
      ),
      home: !_onboardingComplete
          ? OnboardingScreen(
              onComplete: () => setState(() => _onboardingComplete = true),
            )
          : !_sessionReady
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : _sessionRestoreError != null
                  ? _SessionRestoreError(
                      message: _sessionRestoreError!,
                      onRetry: _retrySessionRestore,
                    )
                  : _session == null
              ? AuthScreen(
                  api: _authApi,
                  onAuthenticated: _startAuthenticatedSession,
                )
              : _selectedConcept != null
                  ? LessonScreen(
                      api: _grammarApi,
                      concept: _selectedConcept!,
                      accessToken: _session!.accessToken,
                      onBack: () => setState(() => _selectedConcept = null),
                    )
                  : _showAssessment
                      ? AssessmentScreen(
                          api: _assessmentApi,
                          accessToken: _session!.accessToken,
                          onBack: () => setState(() => _showAssessment = false),
                        )
                  : _showProfile
                  ? ProfileScreen(
                      api: _authApi,
                      accessToken: _session!.accessToken,
                      onLogout: _endSession,
                    )
                  : HomeScreen(
                      repository: _grammarRepository,
                      learningPathApi: _learningPathApi,
                      accessToken: _session!.accessToken,
                      onOpenProfile: () => setState(() => _showProfile = true),
                      onOpenLesson: (concept) =>
                          setState(() => _selectedConcept = concept),
                      onStartAssessment: () =>
                          setState(() => _showAssessment = true),
                    )
    );
  }
}

class _SessionRestoreError extends StatelessWidget {
  const _SessionRestoreError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.tonal(onPressed: onRetry, child: const Text('Tekrar dene')),
              ],
            ),
          ),
        ),
      );
}
