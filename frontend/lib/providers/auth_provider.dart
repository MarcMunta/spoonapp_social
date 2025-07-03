import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'post_provider.dart';

class AuthState {
  final String token;
  final String username;
  const AuthState({required this.token, required this.username});
}

class AuthNotifier extends StateNotifier<AuthState?> {
  AuthNotifier(this.ref) : super(null);

  final Ref ref;

  Future<bool> login(String username, String password) async {
    try {
      final token =
          await ref.read(apiServiceProvider).login(username, password);
      state = AuthState(token: token, username: username);
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
      return true;
    } catch (_) {
      return false;
    }
  }

  void logout() => state = null;
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState?>((ref) => AuthNotifier(ref));
