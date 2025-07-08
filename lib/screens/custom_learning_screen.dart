import 'package:flutter/material.dart';
import '../models/religion.dart';
import '../models/custom_lesson.dart';
import '../services/api_service.dart';
import '../widgets/markdown_widget.dart';
import '../theme/duolingo_theme.dart';
import 'quiz_screen.dart';
import '../widgets/animated_popup.dart';

class CustomLearningScreen extends StatefulWidget {
  final Religion religion;
  
  const CustomLearningScreen({
    super.key,
    required this.religion,
  });

  @override
  State<CustomLearningScreen> createState() => _CustomLearningScreenState();
}

class _CustomLearningScreenState extends State<CustomLearningScreen> {
  final TextEditingController _topicController = TextEditingController();
  String _selectedDifficulty = 'beginner';
  bool _isGenerating = false;
  CustomLesson? _generatedLesson;
  String? _error;

  final List<String> _suggestedTopics = [
    'Prayer and Meditation',
    'Sacred Texts',
    'Ethical Principles',
    'Historical Events',
    'Spiritual Practices',
    'Community Life',
    'Religious Festivals',
    'Philosophical Concepts',
    'Moral Decision Making',
    'Contemporary Issues',
    'Interfaith Dialogue',
    'Personal Growth',
    'Family and Relationships',
    'Work and Ethics',
    'Environmental Stewardship',
  ];

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generateLesson() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      setState(() {
        _error = 'Please enter a topic';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _error = null;
      _generatedLesson = null;
    });

    try {
      // TODO: Replace with actual API call when backend is ready
      await Future.delayed(const Duration(seconds: 2));
      
      // Generate mock lesson for now
      final mockLesson = _generateMockLesson(topic);
      
      setState(() {
        _generatedLesson = mockLesson;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to generate lesson: ${e.toString()}';
        _isGenerating = false;
      });
    }
  }

  CustomLesson _generateMockLesson(String topic) {
    return CustomLesson(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: 1,
      topic: topic,
      religion: widget.religion.name,
      difficulty: _selectedDifficulty,
      content: '''
# $topic in ${widget.religion.name}

## Introduction
This lesson explores the concept of $topic within the context of ${widget.religion.name}. Understanding this topic is essential for deepening your spiritual practice and knowledge.

## Key Concepts

### 1. Historical Background
The practice of $topic has deep roots in ${widget.religion.name} tradition, dating back to ancient times when...

### 2. Core Principles
The fundamental principles of $topic in ${widget.religion.name} include:
- Principle 1: Understanding and respect
- Principle 2: Regular practice and dedication
- Principle 3: Community involvement
- Principle 4: Personal reflection

### 3. Practical Applications
Here are some ways you can incorporate $topic into your daily life:
1. **Daily Practice**: Set aside time each day for...
2. **Study**: Read relevant texts and commentaries
3. **Community**: Connect with others who share your interest
4. **Reflection**: Keep a journal of your experiences

## Exercises and Activities

### Exercise 1: Personal Reflection
Take 10 minutes to reflect on how $topic relates to your personal spiritual journey. Write down your thoughts and feelings.

### Exercise 2: Research Project
Research three different perspectives on $topic within ${widget.religion.name}. Compare and contrast these views.

### Exercise 3: Practical Application
Choose one aspect of $topic and practice it for one week. Document your experiences and insights.

## Quiz Questions

1. What is the primary purpose of $topic in ${widget.religion.name}?
2. How does $topic relate to other spiritual practices?
3. What are the main challenges people face when practicing $topic?
4. How can $topic be adapted for modern life?

## Additional Resources

- Recommended readings on $topic
- Online courses and workshops
- Community groups and discussions
- Expert guidance and mentorship

## Conclusion
$topic is a fundamental aspect of ${widget.religion.name} that offers profound insights and practical benefits for spiritual growth. By understanding and practicing this concept, you can deepen your connection to your faith and enhance your personal development.

Remember to practice regularly and seek guidance from knowledgeable teachers when needed.
      ''',
      estimatedTime: _selectedDifficulty == 'beginner' ? 15 : _selectedDifficulty == 'intermediate' ? 25 : 35,
      exercises: [
        'Reflect on personal experiences with $topic',
        'Research historical context and background',
        'Practice daily application techniques',
        'Connect with community members for discussion',
        'Journal about insights and learnings',
      ],
      quizQuestions: [
        'What is the primary purpose of $topic in ${widget.religion.name}?',
        'How does $topic relate to other spiritual practices?',
        'What are the main challenges people face when practicing $topic?',
        'How can $topic be adapted for modern life?',
      ],
      createdAt: DateTime.now(),
    );
  }

  void _selectTopic(String topic) {
    _topicController.text = topic;
  }

  void _openCustomLesson(CustomLesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomLessonDetailScreen(lesson: lesson),
      ),
    );
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
              child: Text('Custom Learning - ${widget.religion.name}'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Create Your Own Lesson',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose any topic you want to learn about in ${widget.religion.name}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Topic Input
            const Text(
              'What would you like to learn about?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                hintText: 'Enter a topic (e.g., Prayer, Ethics, History...)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            
            // Suggested Topics
            const Text(
              'Suggested Topics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestedTopics.map((topic) => 
                GestureDetector(
                  onTap: () => _selectTopic(topic),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      topic,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                )
              ).toList(),
            ),
            const SizedBox(height: 24),
            
            // Difficulty Selection
            const Text(
              'Difficulty Level',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDifficultyOption('beginner', 'Beginner', 'New to the topic'),
                  const SizedBox(height: 12),
                  _buildDifficultyOption('intermediate', 'Intermediate', 'Some knowledge'),
                  const SizedBox(height: 12),
                  _buildDifficultyOption('advanced', 'Advanced', 'Deep understanding'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateLesson,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isGenerating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Generating Lesson...'),
                        ],
                      )
                    : const Text(
                        'Generate Lesson',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
            
            if (_generatedLesson != null) ...[
              const SizedBox(height: 24),
              _buildGeneratedLesson(_generatedLesson!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyOption(String value, String title, String description) {
    final isSelected = _selectedDifficulty == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDifficulty = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF59E0B).withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFF59E0B) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedDifficulty,
              onChanged: (newValue) {
                setState(() {
                  _selectedDifficulty = newValue!;
                });
              },
              activeColor: const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedLesson(CustomLesson lesson) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFF59E0B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.topic,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      '${lesson.religion} • ${lesson.difficulty} • ${lesson.estimatedTime} min',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Lesson Content',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              lesson.content.split('\n').take(5).join('\n') + '...',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Exercises',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          ...lesson.exercises.take(3).map((exercise) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFFF59E0B),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      exercise,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _openCustomLesson(lesson);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Start Learning'),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomLessonDetailScreen extends StatefulWidget {
  final CustomLesson lesson;

  const CustomLessonDetailScreen({
    super.key,
    required this.lesson,
  });

  @override
  State<CustomLessonDetailScreen> createState() => _CustomLessonDetailScreenState();
}

class _CustomLessonDetailScreenState extends State<CustomLessonDetailScreen> {
  final TextEditingController _reflectionController = TextEditingController();
  int _rating = 0;
  bool _isCompleted = false;
  int _currentQuestionIndex = 0;
  List<String?> _userAnswers = [];
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _userAnswers = List.filled(widget.lesson.quizQuestions.length, null);
  }

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
    setState(() {
      _isCompleted = true;
      _showConfetti = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showConfetti = false);
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuolingoTheme.background,
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
              child: Text(widget.lesson.topic, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: DuolingoTheme.secondary,
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
                      colors: [DuolingoTheme.secondary, DuolingoTheme.accentPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: DuolingoTheme.secondary.withOpacity(0.12),
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
                              color: Colors.white.withOpacity(0.2),
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
                                const Icon(Icons.access_time, size: 16, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.lesson.estimatedTime}m',
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
                        widget.lesson.topic,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Custom lesson 3 ${widget.lesson.difficulty}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Lesson content
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Lesson Content', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DuolingoTheme.textPrimary)),
                      const SizedBox(height: 16),
                      MarkdownWidget(
                        data: widget.lesson.content,
                        padding: const EdgeInsets.all(0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Exercises
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Practical Exercises', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DuolingoTheme.textPrimary)),
                      const SizedBox(height: 16),
                      ...widget.lesson.exercises.asMap().entries.map((entry) {
                        final index = entry.key;
                        final exercise = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: DuolingoTheme.tertiary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DuolingoTheme.tertiary),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  exercise,
                                  style: const TextStyle(fontSize: 15, color: DuolingoTheme.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Quiz Section
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: DuolingoTheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.quiz, color: DuolingoTheme.secondary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Knowledge Quiz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DuolingoTheme.textPrimary)),
                                Text('${widget.lesson.quizQuestions.length} questions to test your understanding', style: TextStyle(fontSize: 14, color: DuolingoTheme.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizScreen(
                                  questions: widget.lesson.quizQuestions,
                                  lessonTitle: widget.lesson.topic,
                                  religion: widget.lesson.religion,
                                  onQuizCompleted: (answers) {
                                    // Handle quiz completion
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Quiz completed successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DuolingoTheme.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_arrow, size: 20),
                              const SizedBox(width: 8),
                              Text('Start Quiz', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
                TextField(
                  controller: _reflectionController,
                  decoration: InputDecoration(
                    hintText: 'What did you learn from this lesson? How will you apply it?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: DuolingoTheme.surfaceVariant,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                // Complete button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isCompleted ? null : _completeLesson,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DuolingoTheme.secondary,
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
} 