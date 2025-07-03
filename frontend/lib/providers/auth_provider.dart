import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'post_provider.dart';

class AuthState {
  final String token;
  final String username;
  const AuthState({required this.token, required this.username});
}

class AuthNotifier extends StateNotifier<AuthState?> {
  AuthNotifier(this.ref) : super(null) {
    _load();
  }

  final Ref ref;
  bool _loading = true;

  bool get loading => _loading;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final username = prefs.getString('username');
    if (token != null && username != null) {
      state = AuthState(token: token, username: username);
    }
    _loading = false;
  }

  Future<bool> login(String username, String password) async {
    try {
      final token =
          await ref.read(apiServiceProvider).login(username, password);
      state = AuthState(token: token, username: username);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('username', username);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> signup(String username, String password) async {
    try {
      final token =
          await ref.read(apiServiceProvider).signup(username, password);
      state = AuthState(token: token, username: username);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('username', username);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
    state = null;
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState?>((ref) => AuthNotifier(ref));
