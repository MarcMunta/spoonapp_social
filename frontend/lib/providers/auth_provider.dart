import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'post_provider.dart';

class AuthNotifier extends StateNotifier<String?> {
  AuthNotifier(this.ref) : super(null);

  final Ref ref;

  Future<bool> login(String username, String password) async {
    try {
      final token =
          await ref.read(apiServiceProvider).login(username, password);
      state = token;
      return true;
    } catch (_) {
      return false;
    }
  }

  void logout() => state = null;
}

final authProvider =
    StateNotifierProvider<AuthNotifier, String?>((ref) => AuthNotifier(ref));
