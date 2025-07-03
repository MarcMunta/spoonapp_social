import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/feed_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/notifications_page.dart';
import 'pages/post_detail_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'models/post.dart';
import 'providers/auth_provider.dart';
GoRouter _buildRouter(AuthState? auth) {
  return GoRouter(
    initialLocation: auth == null ? '/login' : '/',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupPage()),
      ShellRoute(
        builder: (context, state, child) => HomePage(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const FeedPage()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsPage()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
          GoRoute(
            path: '/post/:id',
            builder: (context, state) {
              final post = state.extra as Post;
              return PostDetailPage(post: post);
            },
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final loggedIn = auth != null;
      final loggingIn = state.subloc == '/login' || state.subloc == '/signup';
      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/';
      return null;
    },
  );
}

class SpoonApp extends ConsumerWidget {
  const SpoonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final router = _buildRouter(auth);
    return MaterialApp.router(
      title: 'SpoonApp',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      routerConfig: router,
    );
  }
}
