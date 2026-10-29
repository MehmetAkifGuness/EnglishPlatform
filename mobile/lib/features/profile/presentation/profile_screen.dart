import 'package:flutter/material.dart';

import '../../auth/data/auth_api.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.api,
    required this.accessToken,
    required this.onLogout,
  });

  final AuthApi api;
  final String accessToken;
  final Future<void> Function() onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<AuthUser> _profile;
  bool _loggingOut = false;
  String? _logoutError;

  @override
  void initState() {
    super.initState();
    _profile = widget.api.fetchProfile(widget.accessToken);
  }

  Future<void> _logout() async {
    setState(() {
      _loggingOut = true;
      _logoutError = null;
    });
    try {
      await widget.api.logout(widget.accessToken);
      if (mounted) await widget.onLogout();
    } on Exception {
      if (mounted) {
        setState(() {
          _loggingOut = false;
          _logoutError = 'Çıkış yapılamadı. Bağlantını kontrol edip tekrar dene.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Profilim')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: FutureBuilder<AuthUser>(
            future: _profile,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Profil bilgileri yüklenemedi.'),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => setState(
                            () => _profile = widget.api.fetchProfile(widget.accessToken)),
                        child: const Text('Tekrar dene'),
                      ),
                    ],
                  ),
                );
              }
              final user = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: colors.primaryContainer,
                    child: Text(
                      user.name.trim().isEmpty ? '?' : user.name.trim()[0].toUpperCase(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(user.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                  const SizedBox(height: 5),
                  Text(user.email,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant)),
                  const Spacer(),
                  if (_logoutError != null) ...[
                    Text(_logoutError!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.error)),
                    const SizedBox(height: 10),
                  ],
                  OutlinedButton.icon(
                    onPressed: _loggingOut ? null : _logout,
                    icon: _loggingOut
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout_rounded),
                    label: const Text('Çıkış yap'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
