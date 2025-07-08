import 'package:flutter/material.dart';

class StreakIndicator extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final int streakSavers;

  const StreakIndicator({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.streakSavers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: Colors.orange[300],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '$currentStreak day streak',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Longest: $longestStreak days',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          if (streakSavers > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.red[300],
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '$streakSavers streak saver${streakSavers > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
} 