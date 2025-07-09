import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DuolingoTheme {
  // Duolingo Color Palette
  static const Color primary = Color(0xFF58CC02); // Duolingo Green
  static const Color primaryDark = Color(0xFF4CAF50);
  static const Color secondary = Color(0xFF1CB0F6); // Duolingo Blue
  static const Color tertiary = Color(0xFFFFB800); // Duolingo Yellow
  static const Color quaternary = Color(0xFFFF9600); // Duolingo Orange
  static const Color error = Color(0xFFFF4B4B); // Duolingo Red
  static const Color success = Color(0xFF58CC02);
  static const Color warning = Color(0xFFFFB800);
  static const Color accentPink = Color(0xFFFF5DA2); // Playful Pink
  static const Color accentPurple = Color(0xFF9B51E0); // Playful Purple
  
  // Background Colors
  static const Color background = Color(0xFFF7F7F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF3C3C3C);
  static const Color textSecondary = Color(0xFF777777);
  static const Color textTertiary = Color(0xFFAFAFAF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Border Colors
  static const Color border = Color(0xFFE5E5E5);
  static const Color borderActive = Color(0xFF58CC02);
  
  // Lesson Progress Colors
  static const Color lessonCompleted = Color(0xFF58CC02);
  static const Color lessonCurrent = Color(0xFF1CB0F6);
  static const Color lessonLocked = Color(0xFFE5E5E5);
  
  // Quiz Colors
  static const Color quizCorrect = Color(0xFF58CC02);
  static const Color quizIncorrect = Color(0xFFFF4B4B);
  static const Color quizNeutral = Color(0xFFF7F7F7);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surface,
        background: background,
        error: error,
        onPrimary: textOnPrimary,
        onSecondary: textOnPrimary,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.nunito(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.nunito(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodySmall: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelSmall: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textOnPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderActive, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      scaffoldBackgroundColor: background,
    );
  }
}

// Custom Widget Styles
class DuolingoWidgets {
  static Widget lessonCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isCompleted,
    required bool isLocked,
    bool isCurrent = false,
  }) {
    Color cardColor = DuolingoTheme.surface;
    Color borderColor = DuolingoTheme.border;
    Color iconColor = DuolingoTheme.textTertiary;
    
    if (isCompleted) {
      borderColor = DuolingoTheme.lessonCompleted;
      iconColor = DuolingoTheme.lessonCompleted;
    } else if (isCurrent) {
      borderColor = DuolingoTheme.lessonCurrent;
      iconColor = DuolingoTheme.lessonCurrent;
    } else if (isLocked) {
      cardColor = DuolingoTheme.surfaceVariant;
      iconColor = DuolingoTheme.textTertiary;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : 
                    isLocked ? Icons.lock : Icons.play_circle_outline,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isLocked ? DuolingoTheme.textTertiary : DuolingoTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: DuolingoTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isLocked ? DuolingoTheme.textTertiary : DuolingoTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  static Widget quizOption({
    required String text,
    required VoidCallback onTap,
    bool isSelected = false,
    bool isCorrect = false,
    bool isIncorrect = false,
    bool showResult = false,
  }) {
    Color backgroundColor = DuolingoTheme.quizNeutral;
    Color borderColor = DuolingoTheme.border;
    Color textColor = DuolingoTheme.textPrimary;
    
    if (showResult) {
      if (isCorrect) {
        backgroundColor = DuolingoTheme.quizCorrect.withOpacity(0.1);
        borderColor = DuolingoTheme.quizCorrect;
      } else if (isIncorrect) {
        backgroundColor = DuolingoTheme.quizIncorrect.withOpacity(0.1);
        borderColor = DuolingoTheme.quizIncorrect;
      }
    } else if (isSelected) {
      backgroundColor = DuolingoTheme.secondary.withOpacity(0.1);
      borderColor = DuolingoTheme.secondary;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: textColor,
                    ),
                  ),
                ),
                if (showResult) ...[
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? DuolingoTheme.quizCorrect : DuolingoTheme.quizIncorrect,
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  static Widget progressBar({
    required double progress,
    Color? backgroundColor,
    Color? progressColor,
  }) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: backgroundColor ?? DuolingoTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: progressColor ?? DuolingoTheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
} 