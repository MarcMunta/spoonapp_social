import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/feed_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/notifications_page.dart';
import 'pages/post_detail_page.dart';
import 'pages/new_post_page.dart';
import 'pages/new_story_page.dart';
import 'pages/chat_list_page.dart';
import 'pages/chat_detail_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/edit_profile_page.dart';
import 'pages/friend_requests_page.dart';
import 'pages/blocked_users_page.dart';
import 'pages/user_search_page.dart';
import 'pages/settings_page.dart';
import 'models/post.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'utils/l10n.dart';
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
          GoRoute(path: '/chats', builder: (_, __) => const ChatListPage()),
          GoRoute(
              path: '/friend-requests',
              builder: (_, __) => const FriendRequestsPage()),
          GoRoute(path: '/blocked-users', builder: (_, __) => const BlockedUsersPage()),
          GoRoute(path: '/search', builder: (_, __) => const UserSearchPage()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
          GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfilePage()),
          GoRoute(path: '/new', builder: (_, __) => const NewPostPage()),
          GoRoute(path: '/stories/new', builder: (_, __) => const NewStoryPage()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
          GoRoute(
            path: '/story/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return StoryPage(storyId: id);
            },
          ),
          GoRoute(
            path: '/post/:id',
            builder: (context, state) {
              final post = state.extra as Post;
              return PostDetailPage(post: post);
            },
          ),
          GoRoute(
            path: '/chat/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return ChatDetailPage(chatId: id);
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
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(languageProvider);
    final router = _buildRouter(auth);
    return MaterialApp.router(
      title: 'SpoonApp',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: const [
        DefaultWidgetsLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
