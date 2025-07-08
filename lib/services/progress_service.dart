import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/progress.dart';
import '../models/lesson.dart';
import '../models/religion.dart';
import '../models/chapter.dart';
import 'api_service.dart';

class ProgressService {
  static const String _progressKey = 'user_progress_detailed';
  static const String _lastLessonKey = 'last_lesson_info';
  static const String _currentCourseKey = 'current_course_info';

  // Save detailed progress information
  static Future<void> saveProgress(int userId, int lessonId, String religion, String lessonType, {
    String? chapterTitle,
    int? chapterOrder,
    String? difficulty,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    final progressInfo = {
      'user_id': userId,
      'lesson_id': lessonId,
      'religion': religion,
      'lesson_type': lessonType, // 'comprehensive', 'custom', 'chatbot'
      'chapter_title': chapterTitle,
      'chapter_order': chapterOrder,
      'difficulty': difficulty,
      'completed_at': DateTime.now().toIso8601String(),
    };
    
    // Save as last lesson
    await prefs.setString(_lastLessonKey, jsonEncode(progressInfo));
    
    // Add to progress history
    final progressHistory = await getProgressHistory(userId);
    progressHistory.add(progressInfo);
    await prefs.setString('${_progressKey}_$userId', jsonEncode(progressHistory));
  }

  // Get progress history for a user
  static Future<List<Map<String, dynamic>>> getProgressHistory(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('${_progressKey}_$userId');
    if (historyJson != null) {
      final List<dynamic> history = jsonDecode(historyJson);
      return history.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Get the last lesson info for continue functionality
  static Future<Map<String, dynamic>?> getLastLessonInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLessonJson = prefs.getString(_lastLessonKey);
    if (lastLessonJson != null) {
      return jsonDecode(lastLessonJson);
    }
    return null;
  }

  // Save current course info
  static Future<void> saveCurrentCourse(String religion, String difficulty, int currentChapter) async {
    final prefs = await SharedPreferences.getInstance();
    final courseInfo = {
      'religion': religion,
      'difficulty': difficulty,
      'current_chapter': currentChapter,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_currentCourseKey, jsonEncode(courseInfo));
  }

  // Get current course info
  static Future<Map<String, dynamic>?> getCurrentCourse() async {
    final prefs = await SharedPreferences.getInstance();
    final courseJson = prefs.getString(_currentCourseKey);
    if (courseJson != null) {
      return jsonDecode(courseJson);
    }
    return null;
  }

  // Get next lesson to continue from
  static Future<Map<String, dynamic>?> getNextLesson(int userId) async {
    final lastLesson = await getLastLessonInfo();
    if (lastLesson == null) return null;

    final lessonType = lastLesson['lesson_type'];
    final religion = lastLesson['religion'];

    switch (lessonType) {
      case 'comprehensive':
        return await _getNextComprehensiveLesson(lastLesson);
      case 'custom':
        return await _getNextCustomLesson(userId, religion);
      case 'chatbot':
        return await _getNextChatbotSession(userId, religion);
      default:
        return null;
    }
  }

  // Get next comprehensive lesson
  static Future<Map<String, dynamic>?> _getNextComprehensiveLesson(Map<String, dynamic> lastLesson) async {
    final religion = lastLesson['religion'];
    final currentOrder = lastLesson['chapter_order'] ?? 0;
    final nextOrder = currentOrder + 1;

    // For now, we'll use mock data since we're reducing to 20 chapters
    if (nextOrder <= 20) {
      return {
        'type': 'comprehensive',
        'religion': religion,
        'chapter_order': nextOrder,
        'chapter_title': 'Chapter $nextOrder: ${_getChapterTitle(nextOrder, religion)}',
        'description': 'Continue your structured learning journey',
      };
    }
    return null;
  }

  // Get next custom lesson suggestion
  static Future<Map<String, dynamic>?> _getNextCustomLesson(int userId, String religion) async {
    return {
      'type': 'custom',
      'religion': religion,
      'description': 'Create a new custom lesson on any topic',
      'suggested_topics': _getSuggestedTopics(religion),
    };
  }

  // Get next chatbot session
  static Future<Map<String, dynamic>?> _getNextChatbotSession(int userId, String religion) async {
    return {
      'type': 'chatbot',
      'religion': religion,
      'description': 'Continue your spiritual guidance conversation',
    };
  }

  // Helper method to get chapter titles
  static String _getChapterTitle(int chapterNumber, String religion) {
    final titles = {
      'Islam': [
        'Introduction to Islam',
        'The Five Pillars',
        'Prophet Muhammad',
        'The Quran',
        'Islamic History',
        'Prayer and Worship',
        'Fasting and Ramadan',
        'Charity and Zakat',
        'Pilgrimage to Mecca',
        'Islamic Ethics',
        'Family in Islam',
        'Islamic Art and Culture',
        'Islamic Philosophy',
        'Modern Islam',
        'Islamic Scholarship',
        'Community and Ummah',
        'Islamic Calendar',
        'Islamic Law',
        'Sufism and Spirituality',
        'Islam and Science'
      ],
      'Christianity': [
        'Introduction to Christianity',
        'Life of Jesus Christ',
        'The Bible',
        'Christian History',
        'Prayer and Worship',
        'Christian Ethics',
        'The Trinity',
        'Salvation and Grace',
        'Christian Denominations',
        'Christian Art and Culture',
        'Christian Philosophy',
        'Modern Christianity',
        'Christian Scholarship',
        'Church and Community',
        'Christian Calendar',
        'Christian Theology',
        'Mysticism and Spirituality',
        'Christianity and Science',
        'Christian Mission',
        'Christian Social Teaching'
      ],
      'Hinduism': [
        'Introduction to Hinduism',
        'Hindu Scriptures',
        'Hindu Philosophy',
        'Hindu History',
        'Yoga and Meditation',
        'Hindu Ethics',
        'Hindu Deities',
        'Hindu Rituals',
        'Hindu Festivals',
        'Hindu Art and Culture',
        'Hindu Temples',
        'Modern Hinduism',
        'Hindu Scholarship',
        'Hindu Community',
        'Hindu Calendar',
        'Hindu Theology',
        'Hindu Spirituality',
        'Hinduism and Science',
        'Hindu Traditions',
        'Hindu Wisdom'
      ],
    };

    final religionTitles = titles[religion] ?? [];
    if (chapterNumber > 0 && chapterNumber <= religionTitles.length) {
      return religionTitles[chapterNumber - 1];
    }
    return 'Advanced Topic';
  }

  // Helper method to get suggested topics
  static List<String> _getSuggestedTopics(String religion) {
    switch (religion) {
      case 'Islam':
        return ['Islamic Prayer', 'Quran Study', 'Islamic History', 'Ramadan Preparation'];
      case 'Christianity':
        return ['Bible Study', 'Christian Prayer', 'Church History', 'Christian Living'];
      case 'Hinduism':
        return ['Meditation Practice', 'Hindu Scriptures', 'Yoga Philosophy', 'Hindu Festivals'];
      default:
        return ['Spiritual Practice', 'Religious History', 'Sacred Texts', 'Religious Ethics'];
    }
  }

  // Mark lesson as completed
  static Future<void> markLessonCompleted(int userId, int lessonId, String religion, String lessonType, {
    String? chapterTitle,
    int? chapterOrder,
    String? difficulty,
  }) async {
    await saveProgress(userId, lessonId, religion, lessonType, 
      chapterTitle: chapterTitle,
      chapterOrder: chapterOrder,
      difficulty: difficulty,
    );

    // Update current course if it's comprehensive
    if (lessonType == 'comprehensive' && chapterOrder != null) {
      await saveCurrentCourse(religion, difficulty ?? 'beginner', chapterOrder);
    }
  }

  // Get completion percentage for a religion
  static Future<double> getCompletionPercentage(int userId, String religion) async {
    final progressHistory = await getProgressHistory(userId);
    final religionProgress = progressHistory.where((p) => p['religion'] == religion).toList();
    
    if (religionProgress.isEmpty) return 0.0;
    
    final comprehensiveProgress = religionProgress.where((p) => p['lesson_type'] == 'comprehensive').length;
    return (comprehensiveProgress / 20.0) * 100; // 20 chapters total
  }

  // Clear all progress (for testing)
  static Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastLessonKey);
    await prefs.remove(_currentCourseKey);
  }
} 