import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../theme/duolingo_theme.dart';
import '../widgets/animated_popup.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> with TickerProviderStateMixin {
  late AnimationController _flameController;
  late Animation<double> _flameAnimation;
  bool _isLoading = false;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _flameAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _flameController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _flameController.dispose();
    super.dispose();
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
            const Expanded(
              child: Text('Your Streak'),
            ),
          ],
        ),
        backgroundColor: DuolingoTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final user = userProvider.user;
              if (user == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Streak Display
                    _buildMainStreakCard(user),
                    const SizedBox(height: 24),
                    
                    // Streak Statistics
                    _buildStreakStats(user),
                    const SizedBox(height: 24),
                    
                    // Streak Savers Section
                    _buildStreakSaversSection(user),
                    const SizedBox(height: 24),
                    
                    // Streak Tips
                    _buildStreakTips(),
                    const SizedBox(height: 24),
                    
                    // Streak History (mock for now)
                    _buildStreakHistory(),
                  ],
                ),
              );
            },
          ),
          if (_showConfetti)
            AnimatedPopup(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.celebration, color: DuolingoTheme.accentPink, size: 64),
                  const SizedBox(height: 16),
                  const Text('New Longest Streak!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('You set a new record!'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainStreakCard(user) {
    return GestureDetector(
      onTap: () {
        if (user.currentStreak == user.longestStreak && user.currentStreak > 0) {
          setState(() => _showConfetti = true);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _showConfetti = false);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              DuolingoTheme.primary,
              DuolingoTheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: DuolingoTheme.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Animated Flame Icon
            AnimatedBuilder(
              animation: _flameAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _flameAnimation.value,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.local_fire_department,
                      size: 60,
                      color: Colors.orange[300],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Current Streak
            Text(
              '${user.currentStreak}',
              style: const TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              user.currentStreak == 1 ? 'Day Streak' : 'Day Streak',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            // Motivational Message
            Text(
              _getMotivationalMessage(user.currentStreak),
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakStats(user) {
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
          const Text(
            'Streak Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Current Streak',
                  '${user.currentStreak} days',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Longest Streak',
                  '${user.longestStreak} days',
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Lessons',
                  '${user.totalLessonsCompleted}',
                  Icons.book,
                  DuolingoTheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Streak Savers',
                  '${user.streakSaversAvailable}',
                  Icons.favorite,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSaversSection(user) {
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
              Icon(Icons.favorite, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Streak Savers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            'Streak savers protect your streak when you miss a day. You currently have ${user.streakSaversAvailable} streak saver${user.streakSaversAvailable != 1 ? 's' : ''}.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStreakSaverButton(
                  'Use Streak Saver',
                  user.streakSaversAvailable > 0,
                  () => _useStreakSaver(user.id),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStreakSaverButton(
                  'Buy Streak Savers',
                  true,
                  () => _showPurchaseDialog(user.id),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSaverButton(String text, bool enabled, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? DuolingoTheme.primary : Colors.grey[300],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildStreakTips() {
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
          const Text(
            'Streak Tips',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          
          ..._getStreakTips().map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStreakHistory() {
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
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          
          // Mock streak history
          ..._getMockStreakHistory().map((day) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  day['completed'] ? Icons.check_circle : Icons.cancel,
                  color: day['completed'] ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  day['date'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  day['completed'] ? 'Completed' : 'Missed',
                  style: TextStyle(
                    fontSize: 12,
                    color: day['completed'] ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _getMotivationalMessage(int streak) {
    if (streak == 0) return "Start your spiritual journey today!";
    if (streak < 7) return "Great start! Keep building your habit.";
    if (streak < 30) return "You're on fire! 🔥 Keep it up!";
    if (streak < 100) return "Amazing dedication! You're a true spiritual seeker.";
    return "Incredible! You're a spiritual learning master!";
  }

  List<String> _getStreakTips() {
    return [
      "Set a daily reminder to complete at least one lesson",
      "Start with shorter lessons if you're busy",
      "Use streak savers wisely - save them for unavoidable missed days",
      "Study at the same time each day to build a habit",
      "Even 5 minutes of learning counts towards your streak",
    ];
  }

  List<Map<String, dynamic>> _getMockStreakHistory() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: index));
      return {
        'date': _formatDate(date),
        'completed': index < 5, // Last 5 days completed
      };
    });
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  Future<void> _useStreakSaver(int userId) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.useStreakSaver(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Streak saver used successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh user data
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.refreshUser();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to use streak saver: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPurchaseDialog(int userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Streak Savers'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How many streak savers would you like to purchase?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPurchaseOption(userId, 1, '\$0.99'),
                _buildPurchaseOption(userId, 3, '\$2.49'),
                _buildPurchaseOption(userId, 5, '\$3.99'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseOption(int userId, int quantity, String price) {
    return GestureDetector(
      onTap: () => _purchaseStreakSavers(userId, quantity),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: DuolingoTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: DuolingoTheme.primary.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$quantity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: DuolingoTheme.primary,
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchaseStreakSavers(int userId, int quantity) async {
    Navigator.pop(context);
    
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.purchaseStreakSavers(userId, quantity);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully purchased $quantity streak saver${quantity > 1 ? 's' : ''}!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh user data
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.refreshUser();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 