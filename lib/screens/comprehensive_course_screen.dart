import 'package:flutter/material.dart';
import '../models/religion.dart';
import '../models/lesson.dart';
import '../services/api_service.dart';
import '../screens/lesson_screen.dart';
import '../services/progress_service.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/gamified_lesson_card.dart';
import '../widgets/animated_popup.dart';
import '../theme/duolingo_theme.dart';

class ComprehensiveCourseScreen extends StatefulWidget {
  final Religion religion;
  
  const ComprehensiveCourseScreen({
    super.key,
    required this.religion,
  });

  @override
  State<ComprehensiveCourseScreen> createState() => _ComprehensiveCourseScreenState();
}

class _ComprehensiveCourseScreenState extends State<ComprehensiveCourseScreen> {
  List<Lesson> lessons = [];
  bool isLoading = true;
  String? error;
  int completedLessons = 0;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Load lessons from API
      final fetchedLessons = await ApiService.getLessons(religion: widget.religion.name.toLowerCase());
      
      // Filter only comprehensive lessons and limit to 20
      final comprehensiveLessons = fetchedLessons
          .take(20)
          .toList();
      
      // Sort by ID to maintain order
      comprehensiveLessons.sort((a, b) => a.id.compareTo(b.id));
      
      // Count completed lessons (mock for now - would come from user progress)
      final completed = comprehensiveLessons.where((lesson) => lesson.id <= 3).length;
      
      setState(() {
        lessons = comprehensiveLessons;
        completedLessons = completed;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load lessons: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/Spiritual Guidance Service Logo Spirit Guide.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('${widget.religion.name} Course'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadLessons,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Course Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6750A4), Color(0xFF8B5CF6)],
                        ),
                      ),
                      child: Column(
                        children: [
                          // Religion Icon
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                widget.religion.name[0],
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${widget.religion.name} Comprehensive Course',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '20 comprehensive chapters covering core beliefs, history, and practices',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          // Progress indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$completedLessons',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                ' / ${lessons.length} completed',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Lessons List with Gamified Cards
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: lessons.length,
                        itemBuilder: (context, index) {
                          final lesson = lessons[index];
                          final isCompleted = lesson.id <= 3; // Mock completion status
                          final isCurrent = lesson.id == completedLessons + 1;
                          final isLocked = lesson.id > completedLessons + 1;
                          final progress = isCompleted ? 1.0 : (isCurrent ? 0.3 : 0.0);
                          final xpReward = 10 + (lesson.difficulty == 'intermediate' ? 5 : 0) + (lesson.difficulty == 'advanced' ? 10 : 0);
                          
                          return GamifiedLessonCard(
                            title: lesson.title,
                            subtitle: 'Chapter ${lesson.id}',
                            religion: widget.religion.name,
                            difficulty: lesson.difficulty,
                            duration: lesson.duration,
                            isCompleted: isCompleted,
                            isLocked: isLocked,
                            isCurrent: isCurrent,
                            progress: progress,
                            xpReward: xpReward,
                            onTap: () => _openLesson(lesson),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  void _openLesson(Lesson lesson) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    
    if (user != null) {
      // Save progress before opening lesson
      await ProgressService.saveProgress(
        user.id,
        lesson.id,
        widget.religion.name,
        'comprehensive',
        chapterTitle: lesson.title,
        chapterOrder: lesson.id,
        difficulty: lesson.difficulty,
      );
    }
    
    // Navigate to lesson screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(lesson: lesson),
      ),
    ).then((_) {
      // Check for achievements when returning from lesson
      _checkLessonCompletionAchievements();
    });
  }

  void _checkLessonCompletionAchievements() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) return;

    // Check for course completion achievements
    if (completedLessons == 5) {
      _showAchievementPopup('Course Explorer', 'Completed 5 chapters in ${widget.religion.name}!');
    } else if (completedLessons == 10) {
      _showAchievementPopup('Halfway There', 'Completed 10 chapters in ${widget.religion.name}!');
    } else if (completedLessons == 20) {
      _showAchievementPopup('Course Master', 'Completed the entire ${widget.religion.name} course!');
    }
  }

  void _showAchievementPopup(String achievement, String description) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: AchievementPopup(
          achievement: achievement,
          description: description,
          onDismiss: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
} 