import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      // Aquí deberías hacer la petición real y obtener el token
      // Ejemplo real:
      // final token = await AuthService.login(email, password);
      // Simulación:
      await Future.delayed(const Duration(seconds: 1));
      if ((email == 'alice@example.com' && password == '1234') ||
          (email == 'marc' && password == 'marc')) {
        final token = email == 'alice@example.com' ? 'demo-token-alice' : 'demo-token-marc';
        final userProvider = context.read<UserProvider>();
        userProvider.setToken(token);
        userProvider.setUserByLogin(email);
        // Guarda el token en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        widget.onLoginSuccess();
      } else {
        setState(() {
          _error = 'Credenciales incorrectas';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de red';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      final userProvider = context.read<UserProvider>();
      userProvider.setToken(token);
      // Detección simple de usuario por token demo
      if (token == 'demo-token-alice') {
        userProvider.setUserByLogin('alice@example.com');
      } else if (token == 'demo-token-marc') {
        userProvider.setUserByLogin('marc');
      }
      widget.onLoginSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Iniciar sesión', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                if (_loading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _login();
                      }
                    },
                    child: const Text('Entrar'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
