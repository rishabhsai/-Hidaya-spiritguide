import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../providers/user_provider.dart';
import '../providers/lesson_provider.dart';
import '../widgets/reflection_input.dart';
import '../theme/duolingo_theme.dart';
import '../widgets/animated_popup.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonScreen({
    super.key,
    required this.lesson,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final TextEditingController _reflectionController = TextEditingController();
  int _rating = 0;
  bool _isCompleted = false;
  bool _showConfetti = false;

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  Future<void> _completeLesson() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please rate this lesson before completing it.'),
        ),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final lessonProvider = Provider.of<LessonProvider>(context, listen: false);

    if (userProvider.user == null) return;

    final success = await lessonProvider.completeLesson({
      'user_id': userProvider.user!.id,
      'lesson_id': widget.lesson.id,
      'reflection': _reflectionController.text.trim(),
      'rating': _rating,
    });

    if (success) {
      setState(() {
        _isCompleted = true;
        _showConfetti = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showConfetti = false);
        if (mounted) Navigator.pop(context);
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to complete lesson. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuolingoTheme.background,
      appBar: AppBar(
        title: Text(widget.lesson.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: DuolingoTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lesson header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [DuolingoTheme.primary, DuolingoTheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: DuolingoTheme.primary.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: DuolingoTheme.secondary,
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
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time, size: 16, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.lesson.duration}m',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.lesson.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Lesson content
                Text('Lesson Content', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: DuolingoTheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.lesson.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 24),
                // Practical task
                if (widget.lesson.practicalTask != null) ...[
                  Text('Practical Task', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: DuolingoTheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: DuolingoTheme.secondary, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.lesson.practicalTask!,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: DuolingoTheme.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // Rating
                Text('Rate this lesson', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        size: 32,
                        color: index < _rating ? DuolingoTheme.tertiary : DuolingoTheme.textTertiary,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                // Reflection
                Text('Reflection (Optional)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ReflectionInput(
                  controller: _reflectionController,
                  hintText: 'What did you learn from this lesson? How will you apply it?',
                ),
                const SizedBox(height: 32),
                // Complete button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isCompleted ? null : _completeLesson,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DuolingoTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      _isCompleted ? 'Completed!' : 'Complete Lesson',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          if (_showConfetti)
            AnimatedPopup(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.celebration, color: DuolingoTheme.accentPink, size: 64),
                  const SizedBox(height: 16),
                  const Text('Lesson Completed!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('Great job! You earned XP.'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getReligionColor(String religion) {
    switch (religion.toLowerCase()) {
      case 'christianity':
        return const Color(0xFF2196F3);
      case 'islam':
        return const Color(0xFF4CAF50);
      case 'buddhism':
        return const Color(0xFFFF9800);
      case 'hinduism':
        return const Color(0xFF9C27B0);
      case 'judaism':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFF757575);
    }
  }
} 