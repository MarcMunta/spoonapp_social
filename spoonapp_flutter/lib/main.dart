import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/post_provider.dart';
import 'providers/user_provider.dart';
import 'providers/menu_provider.dart';
import 'screens/feed_page.dart';
import 'screens/splash_router.dart';
import 'screens/create_post_page.dart';
import 'services/backend.dart';

void main() {
  runApp(const SpoonApp());
}

class SpoonApp extends StatelessWidget {
  const SpoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
            create: (_) => PostProvider(BackendService('http://localhost:8000'))),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SpoonApp Social',
        theme: ThemeData(
          fontFamily: GoogleFonts.lato().fontFamily,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB46DDD)),
          scaffoldBackgroundColor: const Color(0xFFFFFFF5),
          useMaterial3: true,
        ),
        routes: {
          '/publish': (_) => const CreatePostPage(),
        },
        home: const SplashRouter(),
      ),
    );
  }
}
