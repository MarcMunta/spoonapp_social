import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/feed_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/post_detail_page.dart';
import 'models/post.dart';

final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => HomePage(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const FeedPage()),
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
);

class SpoonApp extends StatelessWidget {
  const SpoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SpoonApp',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
    );
  }
}
