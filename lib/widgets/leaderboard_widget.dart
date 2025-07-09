import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/duolingo_theme.dart';

class LeaderboardEntry {
  final String name;
  final int xp;
  final int level;
  final int streak;
  final String avatar;
  final int rank;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.name,
    required this.xp,
    required this.level,
    required this.streak,
    required this.avatar,
    required this.rank,
    this.isCurrentUser = false,
  });
}

class LeaderboardWidget extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final String title;
  final VoidCallback? onViewAll;

  const LeaderboardWidget({
    Key? key,
    required this.entries,
    this.title = 'Top Learners',
    this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          // Header
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: DuolingoTheme.secondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: DuolingoTheme.textPrimary,
                ),
              ),
              const Spacer(),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    'View All',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DuolingoTheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Leaderboard entries
          ...entries.take(5).map((entry) => _buildLeaderboardEntry(entry)),
          
          if (entries.length > 5) ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                '... and ${entries.length - 5} more',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: DuolingoTheme.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaderboardEntry(LeaderboardEntry entry) {
    Color rankColor;
    IconData rankIcon;
    
    switch (entry.rank) {
      case 1:
        rankColor = Colors.amber;
        rankIcon = Icons.looks_one;
        break;
      case 2:
        rankColor = Colors.grey[400]!;
        rankIcon = Icons.looks_two;
        break;
      case 3:
        rankColor = Colors.brown[300]!;
        rankIcon = Icons.looks_3;
        break;
      default:
        rankColor = DuolingoTheme.textTertiary;
        rankIcon = Icons.circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: entry.isCurrentUser 
            ? DuolingoTheme.primary.withOpacity(0.1)
            : DuolingoTheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: entry.isCurrentUser
            ? Border.all(color: DuolingoTheme.primary, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Rank indicator
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              rankIcon,
              color: Colors.white,
              size: 18,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: DuolingoTheme.primary.withOpacity(0.1),
            child: Text(
              entry.avatar,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DuolingoTheme.primary,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.name,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DuolingoTheme.textPrimary,
                      ),
                    ),
                    if (entry.isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: DuolingoTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'You',
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Level ${entry.level}',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DuolingoTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 14,
                          color: DuolingoTheme.accentPink,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.streak} days',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: DuolingoTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.xp} XP',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: DuolingoTheme.textPrimary,
                ),
              ),
              Text(
                'Rank #${entry.rank}',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: DuolingoTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WeeklyLeaderboard extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const WeeklyLeaderboard({
    Key? key,
    required this.entries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LeaderboardWidget(
      title: 'This Week\'s Top Learners',
      entries: entries,
      onViewAll: () {
        // TODO: Navigate to full leaderboard
      },
    );
  }
}

class MonthlyLeaderboard extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const MonthlyLeaderboard({
    Key? key,
    required this.entries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LeaderboardWidget(
      title: 'This Month\'s Champions',
      entries: entries,
      onViewAll: () {
        // TODO: Navigate to full leaderboard
      },
    );
  }
}

class AchievementLeaderboard extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const AchievementLeaderboard({
    Key? key,
    required this.entries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LeaderboardWidget(
      title: 'Most Achievements',
      entries: entries,
      onViewAll: () {
        // TODO: Navigate to full leaderboard
      },
    );
  }
} 