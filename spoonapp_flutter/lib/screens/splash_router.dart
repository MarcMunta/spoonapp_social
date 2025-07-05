import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'feed_page.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  bool? _loggedIn;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      // Setea el usuario en el provider para que el perfil esté listo
      final userProvider = context.read<UserProvider>();
      userProvider.setToken(token);
      if (token == 'demo-token-alice') {
        userProvider.setUserByLogin('alice@example.com');
      } else if (token == 'demo-token-marc') {
        userProvider.setUserByLogin('marc');
      }
      setState(() {
        _loggedIn = true;
      });
    } else {
      setState(() {
        _loggedIn = false;
      });
    }
  }

  void _onLoginSuccess() {
    setState(() {
      _loggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loggedIn == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_loggedIn == true) {
      return const FeedPage();
    }
    return LoginPage(onLoginSuccess: _onLoginSuccess);
  }
}
