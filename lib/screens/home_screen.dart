import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/religion.dart';
import '../services/api_service.dart';
import '../services/progress_service.dart';
import '../widgets/streak_indicator.dart';
import '../widgets/learning_mode_card.dart';
import '../widgets/religion_selector.dart';
import '../theme/duolingo_theme.dart';
import 'progress_screen.dart';
import 'comprehensive_course_screen.dart';
import 'custom_learning_screen.dart';
import 'spiritual_guidance_screen.dart';
import 'streak_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Religion> religions = [];
  bool isLoading = true;
  Map<String, dynamic>? nextLesson;

  @override
  void initState() {
    super.initState();
    _loadReligions();
    _updateUserStreak();
    _loadNextLesson();
  }

  Future<void> _loadReligions() async {
    try {
      final loadedReligions = await ApiService.getReligions();
      setState(() {
        religions = loadedReligions.where((r) => ['Islam', 'Christianity', 'Hinduism'].contains(r.name)).toList();
        
        // If no religions from API match our filter, add them manually
        if (religions.isEmpty) {
          religions = _createDefaultReligions();
        }
        
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        // For MVP, use default religions if API fails
        religions = _createDefaultReligions();
        isLoading = false;
      });
    }
  }

  List<Religion> _createDefaultReligions() {
    return [
      Religion(
        id: 1, 
        name: 'Islam', 
        description: 'Islamic teachings and practices', 
        isActive: true, 
        createdAt: DateTime.now()
      ),
      Religion(
        id: 2, 
        name: 'Christianity', 
        description: 'Christian faith and traditions', 
        isActive: true, 
        createdAt: DateTime.now()
      ),
      Religion(
        id: 3, 
        name: 'Hinduism', 
        description: 'Hindu traditions and beliefs', 
        isActive: true, 
        createdAt: DateTime.now()
      ),
    ];
  }

  Future<void> _updateUserStreak() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null) {
      try {
        await ApiService.updateUserStreak(userProvider.user!.id);
        // Refresh user data
        final updatedUser = await ApiService.getUser(userProvider.user!.id);
      } catch (e) {
        // Handle error silently for MVP
      }
    }
  }

  Future<void> _loadNextLesson() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null) {
      final next = await ProgressService.getNextLesson(userProvider.user!.id);
      setState(() {
        nextLesson = next;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuolingoTheme.background,
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

          return Column(
              children: [
              // Custom App Bar with logo in top-left
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    colors: [DuolingoTheme.primary, DuolingoTheme.secondary],
                  ),
                ),
                child: Row(
                  children: [
                    // Logo positioned in top-left
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                ),
              ],
            ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/Spiritual Guidance Service Logo Spirit Guide.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title
                    const Text(
                      'SpiritGuide',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    // Profile button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.person, color: Colors.white, size: 24),
                        onPressed: () {
                          // TODO: Navigate to profile screen
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: CustomScrollView(
                  slivers: [
              // Main Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      // Welcome Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6750A4), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back!',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              user.persona == 'practitioner' 
                                  ? 'Continue your spiritual journey'
                                  : 'Keep exploring world religions',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                          ),
                          const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: StreakIndicator(
                                    currentStreak: user.currentStreak,
                                    longestStreak: user.longestStreak,
                                    streakSavers: user.streakSaversAvailable,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${user.totalLessonsCompleted}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          Text(
                                      'Lessons completed',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Learning Modes Section
                      const Text(
                        'Choose Your Learning Path',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Main Mode (Comprehensive Course)
                      _buildModeTile(
                        title: 'Comprehensive Course',
                        subtitle: 'Complete structured courses like Duolingo',
                        description: 'Follow a complete curriculum with 20 chapters covering the entire history, beliefs, and practices of your chosen religion.',
                        icon: Icons.school,
                        color: DuolingoTheme.primary,
                        onTap: () => _showReligionSelector(context, 'comprehensive'),
                      ),
                      const SizedBox(height: 12),
                      
                      // Custom Mode
                      _buildModeTile(
                        title: 'Custom Lessons',
                        subtitle: 'Learn about specific topics',
                        description: 'Choose any topic or experience you want to learn about. AI generates personalized lessons with quizzes and practical tasks.',
                        icon: Icons.auto_awesome,
                        color: DuolingoTheme.secondary,
                        onTap: () => _showReligionSelector(context, 'custom'),
                      ),
                      const SizedBox(height: 12),
                      
                      // Spiritual Guidance Mode
                      _buildModeTile(
                        title: 'Spiritual Guidance',
                        subtitle: 'Chat with AI spiritual advisor',
                        description: 'Get personalized spiritual guidance through conversation. AI identifies your needs and provides tailored lessons from your chosen faith.',
                        icon: Icons.psychology,
                        color: DuolingoTheme.accent,
                        onTap: () => _showReligionSelector(context, 'chatbot'),
                      ),

                      const SizedBox(height: 24),
                      // Continue Section
                      if (nextLesson != null) ...[
                        const Text(
                          'Continue Learning',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildContinueCard(),
                        const SizedBox(height: 24),
                      ],
                      const SizedBox(height: 24),
                      // Quick Actions
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              'Progress',
                              Icons.trending_up,
                              const Color(0xFF10B981),
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProgressScreen(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              'Streak Savers',
                              Icons.favorite,
                              const Color(0xFFEF4444),
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const StreakScreen(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
                  ],
                ),
              ),
            ],
                            );
                          },
                        ),
                      );
  }

  Widget _buildModeTile({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Mode Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            
            // Mode Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Arrow Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReligionSelector(BuildContext context, String mode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        if (isLoading || religions.isEmpty) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading religions...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return ReligionSelector(
          religions: religions,
          mode: mode,
          onReligionSelected: (religion) {
            Navigator.pop(context);
            _handleModeSelection(mode, religion);
          },
        );
      },
    );
  }

  void _handleModeSelection(String mode, Religion religion) {
    switch (mode) {
      case 'comprehensive':
        _startComprehensiveCourse(religion);
        break;
      case 'custom':
        _startCustomLesson(religion);
        break;
      case 'chatbot':
        _startChatbotSession(religion);
        break;
    }
  }

  void _startComprehensiveCourse(Religion religion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComprehensiveCourseScreen(religion: religion),
      ),
    );
  }

  void _startCustomLesson(Religion religion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomLearningScreen(religion: religion),
      ),
    );
  }

  void _startChatbotSession(Religion religion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpiritualGuidanceScreen(religion: religion),
      ),
    );
  }

  void _showStreakSaverDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StreakScreen(),
      ),
    );
  }

  Widget _buildContinueCard() {
    if (nextLesson == null) return const SizedBox.shrink();

    final lessonType = nextLesson!['type'];
    final religion = nextLesson!['religion'];
    final description = nextLesson!['description'] ?? 'Continue your learning journey';

    IconData icon;
    Color color;
    String title;

    switch (lessonType) {
      case 'comprehensive':
        icon = Icons.school;
        color = DuolingoTheme.primary;
        title = nextLesson!['chapter_title'] ?? 'Next Chapter';
        break;
      case 'custom':
        icon = Icons.auto_awesome;
        color = DuolingoTheme.secondary;
        title = 'Create Custom Lesson';
        break;
      case 'chatbot':
        icon = Icons.psychology;
        color = DuolingoTheme.accent;
        title = 'Spiritual Guidance';
        break;
      default:
        icon = Icons.play_arrow;
        color = DuolingoTheme.primary;
        title = 'Continue Learning';
    }

    return GestureDetector(
      onTap: () => _handleContinueLesson(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            // Continue Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.play_arrow,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            
            // Continue Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continue where you left off',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$religion • $description',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Progress indicator for comprehensive
            if (lessonType == 'comprehensive') ...[
              const SizedBox(width: 12),
              FutureBuilder<double>(
                future: ProgressService.getCompletionPercentage(
                  Provider.of<UserProvider>(context, listen: false).user!.id,
                  religion,
                ),
                builder: (context, snapshot) {
                  final percentage = snapshot.data ?? 0.0;
                  return Column(
                    children: [
                      CircularProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${percentage.toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleContinueLesson() {
    if (nextLesson == null) return;

    final lessonType = nextLesson!['type'];
    final religion = nextLesson!['religion'];

    // Find the religion object
    final religionObj = religions.firstWhere(
      (r) => r.name == religion,
      orElse: () => Religion(
        id: 1,
        name: religion,
        description: '$religion teachings',
        isActive: true,
        createdAt: DateTime.now(),
      ),
    );

    switch (lessonType) {
      case 'comprehensive':
        _startComprehensiveCourse(religionObj);
        break;
      case 'custom':
        _startCustomLesson(religionObj);
        break;
      case 'chatbot':
        _startChatbotSession(religionObj);
        break;
    }
  }
} 