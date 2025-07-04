import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../utils/l10n.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final success = await ref
        .read(authProvider.notifier)
        .login(_userController.text, _passController.text);
    setState(() => _loading = false);
    if (success) {
      if (mounted) context.go('/');
    } else {
      setState(() => _error = L10n.of(ref.read(languageProvider), 'invalid_credentials'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final locale = ref.watch(languageProvider);
    return Scaffold(
      appBar: AppBar(title: Text(L10n.of(locale, 'login'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userController,
              decoration: InputDecoration(labelText: L10n.of(locale, 'username')),
            ),
            TextField(
              controller: _passController,
              decoration: InputDecoration(labelText: L10n.of(locale, 'password')),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child:
                  _loading ? const CircularProgressIndicator() : Text(L10n.of(locale, 'login')),
            ),
            TextButton(
              onPressed: () => context.go('/signup'),
              child: Text(L10n.of(locale, 'signup')),
            ),
          ],
        ),
      ),
    );
  }
}
