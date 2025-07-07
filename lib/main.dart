import 'package:duoreligon/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const DuoreligonApp());
}

class DuoreligonApp extends StatelessWidget {
  const DuoreligonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duoreligon',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      home: const OnboardingScreen(),
    );
  }
}
