import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/duolingo_theme.dart';
import 'progress_tracker.dart';

class GamifiedLessonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String religion;
  final String difficulty;
  final int duration;
  final bool isCompleted;
  final bool isLocked;
  final bool isCurrent;
  final double progress;
  final int xpReward;
  final VoidCallback onTap;

  const GamifiedLessonCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.religion,
    required this.difficulty,
    required this.duration,
    required this.isCompleted,
    required this.isLocked,
    required this.isCurrent,
    required this.progress,
    required this.xpReward,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color cardColor = DuolingoTheme.surface;
    Color borderColor = DuolingoTheme.border;
    Color iconColor = DuolingoTheme.textTertiary;
    Color xpColor = DuolingoTheme.textSecondary;

    if (isCompleted) {
      borderColor = DuolingoTheme.lessonCompleted;
      iconColor = DuolingoTheme.lessonCompleted;
      xpColor = DuolingoTheme.lessonCompleted;
    } else if (isCurrent) {
      borderColor = DuolingoTheme.lessonCurrent;
      iconColor = DuolingoTheme.lessonCurrent;
      xpColor = DuolingoTheme.lessonCurrent;
    } else if (isLocked) {
      cardColor = DuolingoTheme.surfaceVariant;
      iconColor = DuolingoTheme.textTertiary;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? null : onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and XP
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getLessonIcon(),
                        color: iconColor,
                        size: 28,
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
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
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
                    // XP Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: xpColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: xpColor.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: xpColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$xpReward XP',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: xpColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Progress and metadata
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress bar
                          if (!isLocked) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: DuolingoTheme.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isCompleted ? DuolingoTheme.lessonCompleted : DuolingoTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            MiniProgressBar(
                              progress: progress,
                              progressColor: isCompleted ? DuolingoTheme.lessonCompleted : DuolingoTheme.primary,
                            ),
                            const SizedBox(height: 12),
                          ],
                          
                          // Metadata
                          Row(
                            children: [
                              _buildMetadataChip(religion, Icons.church),
                              const SizedBox(width: 8),
                              _buildMetadataChip(difficulty, Icons.speed),
                              const SizedBox(width: 8),
                              _buildMetadataChip('${duration}min', Icons.access_time),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Status indicator
                    if (isCompleted)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: DuolingoTheme.lessonCompleted,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        ),
                      )
                    else if (isCurrent)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: DuolingoTheme.lessonCurrent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      )
                    else if (isLocked)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: DuolingoTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.lock,
                          color: DuolingoTheme.textTertiary,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: DuolingoTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: DuolingoTheme.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: DuolingoTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLessonIcon() {
    if (isCompleted) {
      return Icons.check_circle;
    } else if (isLocked) {
      return Icons.lock;
    } else if (isCurrent) {
      return Icons.play_circle_outline;
    } else {
      return Icons.school;
    }
  }
}

class LessonGridCard extends StatelessWidget {
  final String title;
  final String religion;
  final String difficulty;
  final bool isCompleted;
  final bool isLocked;
  final int xpReward;
  final VoidCallback onTap;

  const LessonGridCard({
    Key? key,
    required this.title,
    required this.religion,
    required this.difficulty,
    required this.isCompleted,
    required this.isLocked,
    required this.xpReward,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color cardColor = DuolingoTheme.surface;
    Color borderColor = DuolingoTheme.border;
    Color iconColor = DuolingoTheme.textTertiary;

    if (isCompleted) {
      borderColor = DuolingoTheme.lessonCompleted;
      iconColor = DuolingoTheme.lessonCompleted;
    } else if (isLocked) {
      cardColor = DuolingoTheme.surfaceVariant;
      iconColor = DuolingoTheme.textTertiary;
    }

    return Container(
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
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                    isLocked ? Icons.lock : Icons.school,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isLocked ? DuolingoTheme.textTertiary : DuolingoTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DuolingoTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$xpReward XP',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: DuolingoTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 