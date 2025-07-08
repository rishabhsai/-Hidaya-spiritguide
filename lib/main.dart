import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/lesson_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'theme/duolingo_theme.dart';

void main() {
  runApp(const SpiritGuideApp());
}

class SpiritGuideApp extends StatelessWidget {
  const SpiritGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LessonProvider()),
      ],
      child: MaterialApp(
        title: 'SpiritGuide',
        theme: DuolingoTheme.lightTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
