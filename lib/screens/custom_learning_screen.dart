import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../theme/duolingo_theme.dart';
import '../widgets/animated_popup.dart';
import '../models/custom_lesson.dart';

class CustomLearningScreen extends StatefulWidget {
  @override
  _CustomLearningScreenState createState() => _CustomLearningScreenState();
}

class _CustomLearningScreenState extends State<CustomLearningScreen> {
  final TextEditingController _topicController = TextEditingController();
  String _selectedReligion = 'islam';
  String _selectedDifficulty = 'beginner';
  bool _isGenerating = false;
  dynamic _generatedLesson;

  final List<String> _religions = ['islam', 'christianity', 'hinduism'];
  final List<String> _difficulties = ['beginner', 'intermediate', 'advanced'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuolingoTheme.background,
      appBar: AppBar(
        title: Text(
          'Custom Learning',
          style: TextStyle(
            color: DuolingoTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: DuolingoTheme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: DuolingoTheme.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DuolingoTheme.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: DuolingoTheme.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'AI-Powered Learning',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Generate personalized lessons on any spiritual topic using AI',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Topic Input
            Text(
              'What would you like to learn about?',
              style: TextStyle(
                color: DuolingoTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                hintText: 'e.g., Prayer, Forgiveness, Meditation, Charity...',
                hintStyle: TextStyle(color: DuolingoTheme.textSecondary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.lightbulb_outline, color: DuolingoTheme.primary),
              ),
              style: TextStyle(
                color: DuolingoTheme.textPrimary,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),

            // Religion Selection
            Text(
              'Choose Religion',
              style: TextStyle(
                color: DuolingoTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Container(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _religions.length,
                itemBuilder: (context, index) {
                  final religion = _religions[index];
                  final isSelected = _selectedReligion == religion;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedReligion = religion),
                    child: Container(
                      margin: EdgeInsets.only(right: 12),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? DuolingoTheme.primary : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? DuolingoTheme.primary : DuolingoTheme.border,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        religion.capitalize(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : DuolingoTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),

            // Difficulty Selection
            Text(
              'Difficulty Level',
              style: TextStyle(
                color: DuolingoTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Container(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _difficulties.length,
                itemBuilder: (context, index) {
                  final difficulty = _difficulties[index];
                  final isSelected = _selectedDifficulty == difficulty;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDifficulty = difficulty),
                    child: Container(
                      margin: EdgeInsets.only(right: 12),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? DuolingoTheme.accentPink : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? DuolingoTheme.accentPink : DuolingoTheme.border,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        difficulty.capitalize(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : DuolingoTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 32),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateLesson,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DuolingoTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: _isGenerating
                    ? Row(
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
                          Text(
                            'Generating...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Generate Lesson',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 24),

            // Generated Lesson Display
            if (_generatedLesson != null) ...[
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.school, color: DuolingoTheme.primary, size: 24),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _generatedLesson?.title ?? 'Generated Lesson',
                            style: TextStyle(
                              color: DuolingoTheme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      _generatedLesson?.content ?? '',
                      style: TextStyle(
                        color: DuolingoTheme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Key Points:',
                      style: TextStyle(
                        color: DuolingoTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    ...(_generatedLesson?.practicalTasks as List<dynamic>? ?? []).map((point) => Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, color: DuolingoTheme.success, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              point.toString(),
                              style: TextStyle(
                                color: DuolingoTheme.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _startLesson(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DuolingoTheme.accentPink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Start Learning',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generateLesson() async {
    if (_topicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a topic to learn about'),
          backgroundColor: DuolingoTheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id ?? 1;
      
      final lesson = await ApiService.generateCustomLesson(
        userId,
        _topicController.text.trim(),
        _selectedReligion,
        _selectedDifficulty,
      );

      setState(() {
        _generatedLesson = lesson;
        _isGenerating = false;
      });

      // Show success popup
      showDialog(
        context: context,
        builder: (context) => AnimatedPopup(
          title: 'Lesson Generated! 🎉',
          message: 'Your personalized lesson on "${_topicController.text.trim()}" is ready to learn!',
          icon: Icons.auto_awesome,
          backgroundColor: DuolingoTheme.success,
        ),
      );

    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate lesson: ${e.toString()}'),
          backgroundColor: DuolingoTheme.error,
        ),
      );
    }
  }

  void _startLesson() {
    // Navigate to lesson screen with generated content
    // This would be implemented to show the full lesson
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start Learning'),
        content: Text('This would open the full lesson with all content, quiz questions, and interactive elements.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
} 