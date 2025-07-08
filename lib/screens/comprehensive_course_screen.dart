import 'package:flutter/material.dart';
import '../models/religion.dart';
import '../models/lesson.dart';
import '../services/api_service.dart';
import '../screens/lesson_screen.dart';
import '../services/progress_service.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

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
      final fetchedLessons = await ApiService.getLessons(widget.religion.name.toLowerCase());
      
      // Filter only comprehensive lessons and limit to 20
      final comprehensiveLessons = fetchedLessons
          .where((lesson) => lesson.lessonType == 'comprehensive')
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
                    // Lessons Grid
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: lessons.length,
                        itemBuilder: (context, index) {
                          final lesson = lessons[index];
                          final isCompleted = lesson.id <= 3; // Mock completion status
                          return _LessonCard(
                            lesson: lesson,
                            isCompleted: isCompleted,
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
        builder: (context) => LessonScreen(
          lesson: lesson,
          religion: widget.religion,
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final bool isCompleted;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0xFF10B981) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? Colors.white.withOpacity(0.2)
                          : const Color(0xFF6750A4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${lesson.id}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCompleted 
                            ? Colors.white
                            : const Color(0xFF6750A4),
                      ),
                    ),
                  ),
                  if (isCompleted)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  lesson.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompleted 
                        ? Colors.white
                        : const Color(0xFF1F2937),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lesson.difficulty.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  color: isCompleted 
                      ? Colors.white.withOpacity(0.8)
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: isCompleted 
                        ? Colors.white.withOpacity(0.8)
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${lesson.duration} min',
                    style: TextStyle(
                      fontSize: 12,
                      color: isCompleted 
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 