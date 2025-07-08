import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/lesson_provider.dart';
import '../models/user.dart';
import '../models/religion.dart';
import '../services/api_service.dart';
import 'lesson_screen.dart';
import 'progress_screen.dart';
import '../widgets/streak_indicator.dart';
import '../widgets/learning_mode_card.dart';
import '../widgets/religion_selector.dart';

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
        religions = loadedReligions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // For MVP, use default religions if API fails
      religions = [
        Religion(id: 1, name: 'Islam', description: 'Islamic teachings and practices', isActive: true, createdAt: DateTime.now()),
        Religion(id: 2, name: 'Christianity', description: 'Christian faith and traditions', isActive: true, createdAt: DateTime.now()),
        Religion(id: 3, name: 'Judaism', description: 'Jewish religion and culture', isActive: true, createdAt: DateTime.now()),
        Religion(id: 4, name: 'Buddhism', description: 'Buddhist philosophy and practices', isActive: true, createdAt: DateTime.now()),
        Religion(id: 5, name: 'Hinduism', description: 'Hindu traditions and beliefs', isActive: true, createdAt: DateTime.now()),
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
        userProvider.updateUser(updatedUser);
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
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF6750A4),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Hidaya',
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
                      LearningModeCard(
                        title: 'Comprehensive Course',
                        subtitle: 'Complete structured courses like Duolingo',
                        description: 'Follow a complete curriculum with 100+ chapters covering the entire history, beliefs, and practices of your chosen religion.',
                        icon: Icons.school,
                        color: const Color(0xFF10B981),
                        onTap: () => _showReligionSelector(context, 'comprehensive'),
                      ),

                      const SizedBox(height: 12),

                      // Custom Mode
                      LearningModeCard(
                        title: 'Custom Lessons',
                        subtitle: 'Learn about specific topics',
                        description: 'Choose any topic or experience you want to learn about. AI generates personalized lessons with quizzes and practical tasks.',
                        icon: Icons.auto_awesome,
                        color: const Color(0xFFF59E0B),
                        onTap: () => _showReligionSelector(context, 'custom'),
                      ),

                      const SizedBox(height: 12),

                      // Chatbot Mode
                      LearningModeCard(
                        title: 'Spiritual Guidance',
                        subtitle: 'Get personal advice and support',
                        description: 'Share your worries and thoughts. Get personalized guidance with relevant verses and lessons from your religion.',
                        icon: Icons.chat_bubble_outline,
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
    // TODO: Navigate to comprehensive course screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting ${religion.name} comprehensive course...')),
    );
  }

  void _startCustomLesson(Religion religion) {
    // TODO: Navigate to custom lesson screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Creating custom lesson for ${religion.name}...')),
    );
  }

  void _startChatbotSession(Religion religion) {
    // TODO: Navigate to chatbot screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting ${religion.name} spiritual guidance...')),
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