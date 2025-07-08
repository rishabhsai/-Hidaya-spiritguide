import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/religion.dart';
import '../services/api_service.dart';
import '../widgets/streak_indicator.dart';
import '../widgets/learning_mode_card.dart';
import '../widgets/religion_selector.dart';
import 'progress_screen.dart';
import 'comprehensive_course_screen.dart';
import 'custom_learning_screen.dart';
import 'spiritual_guidance_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Religion> religions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReligions();
    _updateUserStreak();
  }

  Future<void> _loadReligions() async {
    try {
      final loadedReligions = await ApiService.getReligions();
      setState(() {
        religions = loadedReligions.where((r) => ['Islam', 'Christianity', 'Hinduism'].contains(r.name)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // For MVP, use only supported religions if API fails
      religions = [
        Religion(id: 1, name: 'Islam', description: 'Islamic teachings and practices', isActive: true, createdAt: DateTime.now()),
        Religion(id: 2, name: 'Christianity', description: 'Christian faith and traditions', isActive: true, createdAt: DateTime.now()),
        Religion(id: 3, name: 'Hinduism', description: 'Hindu traditions and beliefs', isActive: true, createdAt: DateTime.now()),
      ];
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              // Hidaya Logo Placeholder
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 32, bottom: 8),
                  child: Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[100],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/Spiritual Guidance Service Logo Spirit Guide.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF6750A4),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'SpiritGuide',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6750A4), Color(0xFF8B5CF6)],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () {
                      // TODO: Navigate to profile screen
                    },
                  ),
                ],
              ),
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
                        description: 'Follow a complete curriculum with 200+ chapters covering the entire history, beliefs, and practices of your chosen religion.',
                        icon: Icons.school,
                        color: const Color(0xFF10B981),
                        onTap: () => _showReligionSelector(context, 'comprehensive'),
                      ),
                      const SizedBox(height: 12),
                      // Custom Mode
                      _buildModeTile(
                        title: 'Custom Lessons',
                        subtitle: 'Learn about specific topics',
                        description: 'Choose any topic or experience you want to learn about. AI generates personalized lessons with quizzes and practical tasks.',
                        icon: Icons.auto_awesome,
                        color: const Color(0xFFF59E0B),
                        onTap: () => _showReligionSelector(context, 'custom'),
                      ),
                      const SizedBox(height: 12),
                      // Spiritual Guidance Mode
                      _buildModeTile(
                        title: 'Spiritual Guidance',
                        subtitle: 'Chat with AI spiritual advisor',
                        description: 'Get personalized spiritual guidance through conversation. AI identifies your needs and provides tailored lessons from your chosen faith.',
                        icon: Icons.psychology,
                        color: const Color(0xFF8B5CF6),
                        onTap: () => _showReligionSelector(context, 'chatbot'),
                      ),

                      const SizedBox(height: 24),
                      // Continue Section
                      if (user.totalLessonsCompleted > 0) ...[
                        const Text(
                          'Continue Learning',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
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
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6750A4).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Color(0xFF6750A4),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Continue where you left off',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Resume your spiritual journey',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey[400],
                                size: 16,
                              ),
                            ],
                          ),
                        ),
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
                              () => _showStreakSaverDialog(context),
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
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
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
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF8B5CF6), size: 18),
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
      builder: (context) => ReligionSelector(
        religions: religions,
        mode: mode,
        onReligionSelected: (religion) {
          Navigator.pop(context);
          _handleModeSelection(mode, religion);
        },
      ),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Streak Savers'),
        content: const Text('Protect your streak with streak savers. Each saver prevents your streak from breaking when you miss a day.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement streak saver purchase
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Streak saver purchase coming soon!')),
              );
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }
} 