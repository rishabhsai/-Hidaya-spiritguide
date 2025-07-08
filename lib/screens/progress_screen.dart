import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/progress.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Progress> _progressData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Replace with actual API call when backend is ready
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate mock progress data for the last 30 days
      final mockProgress = _generateMockProgress();
      
      setState(() {
        _progressData = mockProgress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Progress> _generateMockProgress() {
    final List<Progress> progress = [];
    final now = DateTime.now();
    
    // Generate progress for the last 30 days
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final hasProgress = i % 3 != 0; // Every 3rd day has no progress for demo
      
      if (hasProgress) {
        progress.add(Progress(
          id: i,
          userId: 1,
          lessonId: i + 1,
          completedAt: date,
          timeSpent: 15 + (i % 10),
          rating: 4 + (i % 2),
          moodBefore: 'focused',
          moodAfter: 'inspired',
          reflection: 'Great lesson on ${_getLessonTopic(i)}',
        ));
      }
    }
    
    return progress;
  }

  String _getLessonTopic(int index) {
    final topics = [
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
    ];
    return topics[index % topics.length];
  }

  bool _hasProgressOnDate(DateTime date) {
    return _progressData.any((progress) {
      final progressDate = DateTime(
        progress.completedAt.year,
        progress.completedAt.month,
        progress.completedAt.day,
      );
      final checkDate = DateTime(date.year, date.month, date.day);
      return progressDate.isAtSameMomentAs(checkDate);
    });
  }

  List<Progress> _getProgressForDate(DateTime date) {
    return _progressData.where((progress) {
      final progressDate = DateTime(
        progress.completedAt.year,
        progress.completedAt.month,
        progress.completedAt.day,
      );
      final checkDate = DateTime(date.year, date.month, date.day);
      return progressDate.isAtSameMomentAs(checkDate);
    }).toList();
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
            const Expanded(
              child: Text('Your Progress'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProgressData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Overview
                  _buildProgressOverview(),
                  const SizedBox(height: 24),
                  
                  // Calendar Grid
                  _buildCalendarGrid(),
                  const SizedBox(height: 24),
                  
                  // Recent Activity
                  _buildRecentActivity(),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressOverview() {
    final totalLessons = _progressData.length;
    final thisWeek = _progressData.where((p) {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      return p.completedAt.isAfter(weekAgo);
    }).length;
    final thisMonth = _progressData.where((p) {
      final monthAgo = DateTime.now().subtract(const Duration(days: 30));
      return p.completedAt.isAfter(monthAgo);
    }).length;
    final averageRating = _progressData.isNotEmpty
        ? _progressData.map((p) => p.rating ?? 0).reduce((a, b) => a + b) / _progressData.length
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6750A4), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Your Learning Journey',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Lessons', '$totalLessons', Icons.school),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('This Week', '$thisWeek', Icons.trending_up),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('This Month', '$thisMonth', Icons.calendar_month),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Avg Rating', '${averageRating.toStringAsFixed(1)}', Icons.star),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity Calendar',
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
            children: [
              // Month selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month - 1,
                        );
                      });
                    },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month + 1,
                        );
                      });
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Calendar grid
              _buildCalendarDays(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarDays() {
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;

    return Column(
      children: [
        // Day headers
        Row(
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        
        // Calendar grid
        ...List.generate((daysInMonth + firstWeekday - 1) ~/ 7 + 1, (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
              
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox());
              }
              
              final date = DateTime(_selectedDate.year, _selectedDate.month, dayNumber);
              final hasProgress = _hasProgressOnDate(date);
              final isToday = date.isAtSameMomentAs(DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              ));
              
              return Expanded(
                child: GestureDetector(
                  onTap: () => _showDayDetails(date),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    height: 40,
                    decoration: BoxDecoration(
                      color: hasProgress
                          ? const Color(0xFF10B981)
                          : isToday
                              ? const Color(0xFF6750A4).withOpacity(0.1)
                              : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: isToday
                          ? Border.all(color: const Color(0xFF6750A4), width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: hasProgress
                              ? Colors.white
                              : isToday
                                  ? const Color(0xFF6750A4)
                                  : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final recentProgress = _progressData
        .take(5)
        .toList();

    return Column(
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
        ...recentProgress.map((progress) => _buildActivityCard(progress)),
      ],
    );
  }

  Widget _buildActivityCard(Progress progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF10B981),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lesson Completed',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(progress.completedAt),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (progress.reflection != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    progress.reflection!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (progress.rating != null) ...[
                Row(
                  children: List.generate(5, (index) => Icon(
                    index < progress.rating!
                        ? Icons.star
                        : Icons.star_border,
                    color: const Color(0xFFF59E0B),
                    size: 16,
                  )),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                '${progress.timeSpent} min',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day} ${_getMonthName(date.month)}';
    }
  }

  void _showDayDetails(DateTime date) {
    final dayProgress = _getProgressForDate(date);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${date.day} ${_getMonthName(date.month)} ${date.year}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (dayProgress.isEmpty)
              const Text('No lessons completed on this day.')
            else ...[
              Text(
                '${dayProgress.length} lesson${dayProgress.length > 1 ? 's' : ''} completed',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...dayProgress.map((progress) => ListTile(
                leading: const Icon(Icons.check_circle, color: Color(0xFF10B981)),
                title: Text('Lesson ${progress.lessonId}'),
                subtitle: Text('${progress.timeSpent} minutes'),
                trailing: progress.rating != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) => Icon(
                          index < progress.rating!
                              ? Icons.star
                              : Icons.star_border,
                          color: const Color(0xFFF59E0B),
                          size: 16,
                        )),
                      )
                    : null,
              )),
            ],
          ],
        ),
      ),
    );
  }
} 