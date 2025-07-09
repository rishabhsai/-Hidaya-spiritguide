import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/duolingo_theme.dart';

class DailyChallenge {
  final String title;
  final String description;
  final int xpReward;
  final String icon;
  final bool isCompleted;
  final String type; // 'lesson', 'streak', 'reflection', 'quiz'

  DailyChallenge({
    required this.title,
    required this.description,
    required this.xpReward,
    required this.icon,
    this.isCompleted = false,
    required this.type,
  });
}

class DailyChallengeWidget extends StatelessWidget {
  final List<DailyChallenge> challenges;
  final VoidCallback? onChallengeTap;

  const DailyChallengeWidget({
    Key? key,
    required this.challenges,
    this.onChallengeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final completedCount = challenges.where((c) => c.isCompleted).length;
    final totalCount = challenges.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DuolingoTheme.primary,
            DuolingoTheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: DuolingoTheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Challenges',
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Complete challenges to earn bonus XP!',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress indicator
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          '$completedCount/$totalCount',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Challenges list
          ...challenges.map((challenge) => _buildChallengeCard(challenge)),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(DailyChallenge challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: challenge.isCompleted 
            ? Colors.white.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: challenge.isCompleted
            ? Border.all(color: Colors.white, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Challenge icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: challenge.isCompleted 
                  ? Colors.white
                  : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getChallengeIcon(challenge.type),
              color: challenge.isCompleted 
                  ? DuolingoTheme.primary
                  : Colors.white,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Challenge info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  challenge.description,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          // XP reward and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${challenge.xpReward} XP',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (challenge.isCompleted)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: DuolingoTheme.primary,
                    size: 16,
                  ),
                )
              else
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lock_open,
                    color: Colors.white.withOpacity(0.6),
                    size: 14,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getChallengeIcon(String type) {
    switch (type) {
      case 'lesson':
        return Icons.school;
      case 'streak':
        return Icons.local_fire_department;
      case 'reflection':
        return Icons.psychology;
      case 'quiz':
        return Icons.quiz;
      default:
        return Icons.star;
    }
  }
}

class WeeklyGoalWidget extends StatelessWidget {
  final int currentProgress;
  final int targetGoal;
  final String goalType;
  final int xpReward;

  const WeeklyGoalWidget({
    Key? key,
    required this.currentProgress,
    required this.targetGoal,
    required this.goalType,
    required this.xpReward,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = targetGoal > 0 ? currentProgress / targetGoal : 0.0;
    final isCompleted = currentProgress >= targetGoal;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DuolingoTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? DuolingoTheme.lessonCompleted : DuolingoTheme.border,
          width: 2,
        ),
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? DuolingoTheme.lessonCompleted.withOpacity(0.1)
                      : DuolingoTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.flag,
                  color: isCompleted ? DuolingoTheme.lessonCompleted : DuolingoTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Goal',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: DuolingoTheme.textPrimary,
                      ),
                    ),
                    Text(
                      goalType,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: DuolingoTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DuolingoTheme.lessonCompleted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'COMPLETED!',
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentProgress / $targetGoal',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: DuolingoTheme.textPrimary,
                ),
              ),
              Text(
                '+$xpReward XP',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DuolingoTheme.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
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
    );
  }
} 