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
import '../widgets/pigeon_avatar.dart';
import 'progress_screen.dart';
import 'comprehensive_course_screen.dart';
import 'custom_learning_screen.dart';
import 'spiritual_guidance_screen.dart';
import 'streak_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Religion> religions = [];
  bool isLoading = true;
  Map<String, dynamic>? nextLesson;
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadReligions();
    _updateUserStreak();
    _loadNextLesson();
  }

  void _setupAnimations() {
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
    _bounceController.forward();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _fadeController.dispose();
    super.dispose();
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF58CC02),
              Color(0xFF1CB0F6),
              Color(0xFFF7F7F7),
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final user = userProvider.user;
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Animated Header
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Top Row with Logo and Profile
                            Row(
                              children: [
                                // Animated Logo
                                ScaleTransition(
                                  scale: _bounceAnimation,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        'assets/images/Spiritual Guidance Service Logo Spirit Guide.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Title
                                Expanded(
                                  child: Text(
                                    'SpiritGuide',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.2),
                                          offset: const Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Profile Avatar (Pigeon)
                                GestureDetector(
                                  onTap: () {
                                    // TODO: Navigate to profile
                                  },
                                  child: PigeonAvatar(size: 50),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Welcome Card
                            _buildWelcomeCard(user),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Main Content
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: DuolingoTheme.background,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            // Continue Learning Section
                            if (nextLesson != null) ...[
                              _buildContinueLearningSection(),
                              const SizedBox(height: 32),
                            ],
                            // Learning Modes
                            _buildLearningModesSection(),
                            const SizedBox(height: 32),
                            // Quick Actions
                            _buildQuickActionsSection(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(user) {
    return ScaleTransition(
      scale: _bounceAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Greeting
            Text(
              'Welcome back! 👋',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: DuolingoTheme.textPrimary,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Stats Row
            Row(
              children: [
                // Streak
                Expanded(
                  child: _buildStatCard(
                    '🔥',
                    '${user.currentStreak}',
                    'Day Streak',
                    DuolingoTheme.quaternary,
                  ),
                ),
                const SizedBox(width: 12),
                // Lessons
                Expanded(
                  child: _buildStatCard(
                    '📚',
                    '${user.totalLessonsCompleted}',
                    'Lessons',
                    DuolingoTheme.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                // Streak Savers
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StreakScreen()),
                    ),
                    child: _buildStatCard(
                      '💎',
                      '${user.streakSaversAvailable}',
                      'Savers',
                      DuolingoTheme.accentPink,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: DuolingoTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearningSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Continue Learning',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: DuolingoTheme.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        _buildContinueCard(),
      ],
    );
  }

  Widget _buildLearningModesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Path',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: DuolingoTheme.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        _buildGameModeCard(
          '🎓',
          'Comprehensive Course',
          'Complete structured curriculum',
          'Learn everything about your chosen religion through 20 engaging chapters',
          DuolingoTheme.primary,
          () => _showReligionSelector(context, 'comprehensive'),
        ),
        const SizedBox(height: 16),
        _buildGameModeCard(
          '✨',
          'Custom Lessons',
          'AI-powered personalized learning',
          'Choose any topic and get instant lessons tailored just for you',
          DuolingoTheme.secondary,
          () => _showReligionSelector(context, 'custom'),
        ),
        const SizedBox(height: 16),
        _buildGameModeCard(
          '🧘',
          'Spiritual Guidance',
          'Chat with AI spiritual advisor',
          'Get personalized guidance through meaningful conversations',
          DuolingoTheme.accentPurple,
          () => _showReligionSelector(context, 'chatbot'),
        ),
      ],
    );
  }

  Widget _buildGameModeCard(
    String emoji,
    String title,
    String subtitle,
    String description,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color.withOpacity(0.2), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Emoji Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: DuolingoTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: DuolingoTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: DuolingoTheme.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                '📈',
                'Progress',
                'View your stats',
                DuolingoTheme.success,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProgressScreen()),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                '🏆',
                'Leaderboard',
                'Compete with others',
                DuolingoTheme.tertiary,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String emoji,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: DuolingoTheme.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DuolingoTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
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
        color = DuolingoTheme.accentPink;
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

  void _showStreakPopup() {
    showDialog(
      context: context,
      builder: (context) => AnimatedPopup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥 Streak Achieved!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('You kept your streak going!'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Awesome!'),
            ),
          ],
        ),
      ),
    );
  }
} 