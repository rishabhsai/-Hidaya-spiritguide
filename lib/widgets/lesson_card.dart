import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../theme/duolingo_theme.dart';

class LessonCard extends StatefulWidget {
  final Lesson lesson;
  final VoidCallback onTap;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.onTap,
  });

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _controller.reverse();
    await _controller.forward();
    setState(() => _showConfetti = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showConfetti = false);
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getReligionColor(widget.lesson.religion).withOpacity(0.15),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: _getReligionColor(widget.lesson.religion).withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: _handleTap,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: _getReligionColor(widget.lesson.religion),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.lesson.religion.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: DuolingoTheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time, size: 16, color: DuolingoTheme.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.lesson.duration}m',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: DuolingoTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        widget.lesson.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: DuolingoTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.lesson.content,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: DuolingoTheme.textSecondary,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      // XP/Progress bar
                      Row(
                        children: [
                          Icon(Icons.star, size: 18, color: DuolingoTheme.tertiary),
                          const SizedBox(width: 4),
                          Text(
                            widget.lesson.difficulty.toUpperCase(),
                            style: TextStyle(
                              fontSize: 13,
                              color: DuolingoTheme.tertiary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_forward_ios, size: 18, color: DuolingoTheme.textTertiary),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Progress bar (fake for demo)
                      LinearProgressIndicator(
                        value: (widget.lesson.progress ?? 0) / 100,
                        backgroundColor: DuolingoTheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(DuolingoTheme.primary),
                        minHeight: 7,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Confetti animation (demo)
        if (_showConfetti)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Icon(Icons.celebration, color: DuolingoTheme.accentPink, size: 64),
              ),
            ),
          ),
      ],
    );
  }

  Color _getReligionColor(String religion) {
    switch (religion.toLowerCase()) {
      case 'christianity':
        return DuolingoTheme.secondary;
      case 'islam':
        return DuolingoTheme.primary;
      case 'hinduism':
        return DuolingoTheme.accentPurple;
      default:
        return DuolingoTheme.textTertiary;
    }
  }
} 