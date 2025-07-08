import 'package:flutter/material.dart';
import '../models/religion.dart';
import '../models/course.dart';
import '../models/chapter.dart';
import '../services/api_service.dart';

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
  List<Chapter> chapters = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // TODO: Replace with actual API call when backend is ready
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate mock chapters for now
      final mockChapters = _generateMockChapters();
      
      setState(() {
        chapters = mockChapters;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load chapters: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  List<Chapter> _generateMockChapters() {
    final List<Chapter> mockChapters = [];
    
    // Generate 200 chapters with different categories
    final categories = [
      'Foundations',
      'History',
      'Beliefs',
      'Practices',
      'Scriptures',
      'Philosophy',
      'Ethics',
      'Rituals',
      'Community',
      'Modern Applications'
    ];

    for (int i = 1; i <= 200; i++) {
      final category = categories[(i - 1) % categories.length];
      final level = i <= 50 ? 'Beginner' : i <= 100 ? 'Intermediate' : 'Advanced';
      
      mockChapters.add(Chapter(
        id: i,
        courseId: 1,
        title: 'Chapter $i: ${_generateChapterTitle(i, category)}',
        content: 'This is chapter $i content...',
        category: category,
        difficulty: level,
        estimatedTime: 15 + (i % 10),
        isCompleted: i <= 5, // First 5 chapters completed for demo
        order: i,
        createdAt: DateTime.now(),
      ));
    }
    
    return mockChapters;
  }

  String _generateChapterTitle(int chapterNumber, String category) {
    final titles = {
      'Foundations': [
        'Introduction to ${widget.religion.name}',
        'Core Principles',
        'Basic Beliefs',
        'Fundamental Concepts',
        'Essential Teachings'
      ],
      'History': [
        'Historical Origins',
        'Early Development',
        'Key Historical Figures',
        'Major Events',
        'Historical Timeline'
      ],
      'Beliefs': [
        'Central Beliefs',
        'Theological Concepts',
        'Divine Nature',
        'Human Nature',
        'Purpose of Life'
      ],
      'Practices': [
        'Daily Practices',
        'Worship Methods',
        'Meditation Techniques',
        'Prayer Forms',
        'Ritual Practices'
      ],
      'Scriptures': [
        'Sacred Texts',
        'Scriptural Interpretation',
        'Key Passages',
        'Textual Analysis',
        'Scriptural Wisdom'
      ],
      'Philosophy': [
        'Philosophical Foundations',
        'Ethical Framework',
        'Metaphysical Concepts',
        'Epistemology',
        'Philosophical Debates'
      ],
      'Ethics': [
        'Moral Principles',
        'Ethical Guidelines',
        'Virtue Development',
        'Moral Decision Making',
        'Ethical Dilemmas'
      ],
      'Rituals': [
        'Ceremonial Practices',
        'Ritual Significance',
        'Sacred Ceremonies',
        'Ritual Preparation',
        'Ceremonial Objects'
      ],
      'Community': [
        'Community Structure',
        'Leadership Roles',
        'Social Organization',
        'Community Values',
        'Collective Practices'
      ],
      'Modern Applications': [
        'Contemporary Relevance',
        'Modern Challenges',
        'Adaptation to Today',
        'Current Issues',
        'Future Directions'
      ]
    };

    final categoryTitles = titles[category] ?? ['General Topic'];
    return categoryTitles[chapterNumber % categoryTitles.length];
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
                        onPressed: _loadChapters,
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
                          // Religion Icon Placeholder
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
                            '200 chapters covering the complete history, beliefs, and practices',
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
                                '${chapters.where((c) => c.isCompleted).length}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                ' / ${chapters.length} completed',
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
                    // Chapters Grid
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: chapters.length,
                        itemBuilder: (context, index) {
                          final chapter = chapters[index];
                          return _ChapterCard(
                            chapter: chapter,
                            onTap: () => _openChapter(chapter),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  void _openChapter(Chapter chapter) {
    // TODO: Navigate to chapter detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${chapter.title}...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.chapter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: chapter.isCompleted ? const Color(0xFF10B981) : Colors.white,
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
                      color: chapter.isCompleted 
                          ? Colors.white.withOpacity(0.2)
                          : const Color(0xFF6750A4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${chapter.order}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: chapter.isCompleted 
                            ? Colors.white
                            : const Color(0xFF6750A4),
                      ),
                    ),
                  ),
                  if (chapter.isCompleted)
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
                  chapter.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: chapter.isCompleted 
                        ? Colors.white
                        : const Color(0xFF1F2937),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                chapter.category,
                style: TextStyle(
                  fontSize: 12,
                  color: chapter.isCompleted 
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
                    color: chapter.isCompleted 
                        ? Colors.white.withOpacity(0.8)
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${chapter.estimatedTime} min',
                    style: TextStyle(
                      fontSize: 12,
                      color: chapter.isCompleted 
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