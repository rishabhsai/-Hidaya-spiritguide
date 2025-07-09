import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/duolingo_theme.dart';

class ProgressTracker extends StatelessWidget {
  final int currentXP;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final int lessonsCompleted;
  final int targetXP;

  const ProgressTracker({
    Key? key,
    required this.currentXP,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
    required this.lessonsCompleted,
    required this.targetXP,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = currentXP / targetXP;
    final xpToNextLevel = targetXP - currentXP;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DuolingoTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DuolingoTheme.border, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level and XP Section
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: DuolingoTheme.primary,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: DuolingoTheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    level.toString(),
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level $level',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: DuolingoTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentXP / $targetXP XP',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DuolingoTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // XP Progress Bar
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: DuolingoTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                DuolingoTheme.primary,
                                DuolingoTheme.accentPink,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_fire_department,
                  title: 'Current Streak',
                  value: '$currentStreak days',
                  color: DuolingoTheme.accentPink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.emoji_events,
                  title: 'Longest Streak',
                  value: '$longestStreak days',
                  color: DuolingoTheme.secondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  title: 'Lessons Completed',
                  value: lessonsCompleted.toString(),
                  color: DuolingoTheme.lessonCompleted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up,
                  title: 'XP to Next Level',
                  value: xpToNextLevel.toString(),
                  color: DuolingoTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DuolingoTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: DuolingoTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class MiniProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;

  const MiniProgressBar({
    Key? key,
    required this.progress,
    this.height = 6,
    this.backgroundColor,
    this.progressColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? DuolingoTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                progressColor ?? DuolingoTheme.primary,
                progressColor ?? DuolingoTheme.accentPink,
              ],
            ),
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

class StreakIndicator extends StatelessWidget {
  final int streak;
  final bool isActive;

  const StreakIndicator({
    Key? key,
    required this.streak,
    this.isActive = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? DuolingoTheme.accentPink : DuolingoTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? DuolingoTheme.accentPink : DuolingoTheme.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: isActive ? Colors.white : DuolingoTheme.textTertiary,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            streak.toString(),
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : DuolingoTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
} 