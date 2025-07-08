import 'package:flutter/material.dart';
import '../theme/duolingo_theme.dart';
import '../widgets/pigeon_avatar.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> leaderboard = [
      {'name': 'You', 'xp': 3200, 'rank': 1},
      {'name': 'Aisha', 'xp': 2900, 'rank': 2},
      {'name': 'Ravi', 'xp': 2500, 'rank': 3},
      {'name': 'Sara', 'xp': 2100, 'rank': 4},
      {'name': 'John', 'xp': 1800, 'rank': 5},
    ];
    return Scaffold(
      backgroundColor: DuolingoTheme.background,
      appBar: AppBar(
        title: const Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: DuolingoTheme.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Learners This Week',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: DuolingoTheme.textPrimary),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: leaderboard.length,
                itemBuilder: (context, index) {
                  final user = leaderboard[index];
                  final isYou = user['name'] == 'You';
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isYou ? DuolingoTheme.primary.withOpacity(0.15) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: DuolingoTheme.secondary.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: isYou ? Border.all(color: DuolingoTheme.primary, width: 2) : null,
                    ),
                    child: ListTile(
                      leading: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          PigeonAvatar(size: 48),
                          if (user['rank'] <= 3)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: user['rank'] == 1
                                    ? DuolingoTheme.tertiary
                                    : user['rank'] == 2
                                        ? DuolingoTheme.secondary
                                        : DuolingoTheme.accentPink,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${user['rank']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        user['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isYou ? DuolingoTheme.primary : DuolingoTheme.textPrimary,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Icon(Icons.star, color: DuolingoTheme.tertiary, size: 18),
                          const SizedBox(width: 4),
                          Text('${user['xp']} XP', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      trailing: AnimatedScale(
                        scale: isYou ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          isYou ? Icons.emoji_events : Icons.emoji_events_outlined,
                          color: isYou ? DuolingoTheme.primary : DuolingoTheme.textTertiary,
                          size: 32,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 