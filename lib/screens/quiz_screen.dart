import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/duolingo_theme.dart';
import '../models/custom_lesson.dart';

class QuizScreen extends StatefulWidget {
  final List<String> questions;
  final String lessonTitle;
  final String religion;
  final Function(List<String>) onQuizCompleted;

  const QuizScreen({
    super.key,
    required this.questions,
    required this.lessonTitle,
    required this.religion,
    required this.onQuizCompleted,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  List<String> userAnswers = [];
  String currentAnswer = '';
  bool isAnswerSubmitted = false;
  bool showResult = false;
  
  late AnimationController _progressController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    userAnswers = List.filled(widget.questions.length, '');
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    _slideController.forward();
    _updateProgress();
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    _slideController.dispose();
    super.dispose();
  }
  
  void _updateProgress() {
    final progress = (currentQuestionIndex + 1) / widget.questions.length;
    _progressController.animateTo(progress);
  }
  
  void _submitAnswer() {
    if (currentAnswer.trim().isEmpty) return;
    
    setState(() {
      isAnswerSubmitted = true;
      showResult = true;
      userAnswers[currentQuestionIndex] = currentAnswer;
    });
    
    // Auto-advance after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }
  
  void _nextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        currentAnswer = userAnswers[currentQuestionIndex];
        isAnswerSubmitted = false;
        showResult = false;
      });
      
      _slideController.reset();
      _slideController.forward();
      _updateProgress();
    } else {
      // Quiz completed
      widget.onQuizCompleted(userAnswers);
      Navigator.pop(context);
    }
  }
  
  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        currentAnswer = userAnswers[currentQuestionIndex];
        isAnswerSubmitted = false;
        showResult = false;
      });
      
      _slideController.reset();
      _slideController.forward();
      _updateProgress();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuolingoTheme.background,
      appBar: AppBar(
        backgroundColor: DuolingoTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: DuolingoTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Quiz',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: DuolingoTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${currentQuestionIndex + 1} of ${widget.questions.length}',
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: DuolingoTheme.textSecondary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return DuolingoWidgets.progressBar(
                  progress: _progressController.value,
                );
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Question
                    Text(
                      'Question ${currentQuestionIndex + 1}',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DuolingoTheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: DuolingoTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: DuolingoTheme.border,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.questions[currentQuestionIndex],
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: DuolingoTheme.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Answer input
                    Text(
                      'Your Answer',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DuolingoTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: DuolingoTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: showResult 
                              ? DuolingoTheme.primary
                              : DuolingoTheme.border,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: TextEditingController(text: currentAnswer),
                        onChanged: (value) {
                          setState(() {
                            currentAnswer = value;
                          });
                        },
                        enabled: !isAnswerSubmitted,
                        maxLines: 3,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: DuolingoTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type your answer here...',
                          hintStyle: GoogleFonts.nunito(
                            color: DuolingoTheme.textSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Result feedback
                    if (showResult) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: DuolingoTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: DuolingoTheme.primary,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: DuolingoTheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Answer recorded! Moving to next question...',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: DuolingoTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom navigation
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: DuolingoTheme.surface,
              border: Border(
                top: BorderSide(
                  color: DuolingoTheme.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Previous button
                if (currentQuestionIndex > 0)
                  OutlinedButton(
                    onPressed: isAnswerSubmitted ? null : _previousQuestion,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: DuolingoTheme.border),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'Previous',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DuolingoTheme.textSecondary,
                      ),
                    ),
                  ),
                
                const Spacer(),
                
                // Submit/Next button
                ElevatedButton(
                  onPressed: isAnswerSubmitted || currentAnswer.trim().isEmpty 
                      ? null 
                      : _submitAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DuolingoTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isAnswerSubmitted 
                        ? 'Processing...'
                        : currentQuestionIndex == widget.questions.length - 1
                            ? 'Finish Quiz'
                            : 'Submit Answer',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 