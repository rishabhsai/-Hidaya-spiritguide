import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/lesson.dart';
import '../models/progress.dart';
import '../models/religion.dart';
import '../models/course.dart';
import '../models/custom_lesson.dart';
import '../models/chatbot_session.dart';

class LocalStorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  // User data storage
  static const String _userKey = 'current_user';
  static const String _userProgressKey = 'user_progress';
  static const String _userStreakKey = 'user_streak';
  static const String _userPreferencesKey = 'user_preferences';
  
  // Offline data storage
  static const String _cachedLessonsKey = 'cached_lessons';
  static const String _cachedReligionsKey = 'cached_religions';
  static const String _cachedCoursesKey = 'cached_courses';
  static const String _cachedCustomLessonsKey = 'cached_custom_lessons';
  static const String _cachedChatbotSessionsKey = 'cached_chatbot_sessions';
  
  // App state storage
  static const String _lastSyncKey = 'last_sync';
  static const String _offlineModeKey = 'offline_mode';
  static const String _onboardingCompleteKey = 'onboarding_complete';

  // User Management
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // User Progress Management
  static Future<void> saveUserProgress(List<UserProgress> progress) async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = progress.map((p) => p.toJson()).toList();
    await prefs.setString(_userProgressKey, jsonEncode(progressJson));
  }

  static Future<List<UserProgress>> getUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_userProgressKey);
    if (progressJson != null) {
      List<dynamic> data = jsonDecode(progressJson);
      return data.map((json) => UserProgress.fromJson(json)).toList();
    }
    return [];
  }

  static Future<void> addProgress(UserProgress progress) async {
    final currentProgress = await getUserProgress();
    currentProgress.add(progress);
    await saveUserProgress(currentProgress);
  }

  // Streak Management
  static Future<void> saveUserStreak(int streak, DateTime lastActivity) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userStreakKey, streak);
    await prefs.setString('last_activity', lastActivity.toIso8601String());
  }

  static Future<Map<String, dynamic>> getUserStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final streak = prefs.getInt(_userStreakKey) ?? 0;
    final lastActivityStr = prefs.getString('last_activity');
    final lastActivity = lastActivityStr != null 
        ? DateTime.parse(lastActivityStr) 
        : DateTime.now();
    
    return {
      'streak': streak,
      'last_activity': lastActivity,
    };
  }

  // User Preferences
  static Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPreferencesKey, jsonEncode(preferences));
  }

  static Future<Map<String, dynamic>> getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = prefs.getString(_userPreferencesKey);
    if (preferencesJson != null) {
      return jsonDecode(preferencesJson);
    }
    return {};
  }

  // Offline Data Caching
  static Future<void> cacheLessons(List<Lesson> lessons) async {
    final prefs = await SharedPreferences.getInstance();
    final lessonsJson = lessons.map((l) => l.toJson()).toList();
    await prefs.setString(_cachedLessonsKey, jsonEncode(lessonsJson));
  }

  static Future<List<Lesson>> getCachedLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final lessonsJson = prefs.getString(_cachedLessonsKey);
    if (lessonsJson != null) {
      List<dynamic> data = jsonDecode(lessonsJson);
      return data.map((json) => Lesson.fromJson(json)).toList();
    }
    return [];
  }

  static Future<void> cacheReligions(List<Religion> religions) async {
    final prefs = await SharedPreferences.getInstance();
    final religionsJson = religions.map((r) => r.toJson()).toList();
    await prefs.setString(_cachedReligionsKey, jsonEncode(religionsJson));
  }

  static Future<List<Religion>> getCachedReligions() async {
    final prefs = await SharedPreferences.getInstance();
    final religionsJson = prefs.getString(_cachedReligionsKey);
    if (religionsJson != null) {
      List<dynamic> data = jsonDecode(religionsJson);
      return data.map((json) => Religion.fromJson(json)).toList();
    }
    return [];
  }

  static Future<void> cacheCourses(List<Course> courses) async {
    final prefs = await SharedPreferences.getInstance();
    final coursesJson = courses.map((c) => c.toJson()).toList();
    await prefs.setString(_cachedCoursesKey, jsonEncode(coursesJson));
  }

  static Future<List<Course>> getCachedCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final coursesJson = prefs.getString(_cachedCoursesKey);
    if (coursesJson != null) {
      List<dynamic> data = jsonDecode(coursesJson);
      return data.map((json) => Course.fromJson(json)).toList();
    }
    return [];
  }

  static Future<void> cacheCustomLessons(List<CustomLesson> lessons) async {
    final prefs = await SharedPreferences.getInstance();
    final lessonsJson = lessons.map((l) => l.toJson()).toList();
    await prefs.setString(_cachedCustomLessonsKey, jsonEncode(lessonsJson));
  }

  static Future<List<CustomLesson>> getCachedCustomLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final lessonsJson = prefs.getString(_cachedCustomLessonsKey);
    if (lessonsJson != null) {
      List<dynamic> data = jsonDecode(lessonsJson);
      return data.map((json) => CustomLesson.fromJson(json)).toList();
    }
    return [];
  }

  static Future<void> cacheChatbotSessions(List<ChatbotSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_cachedChatbotSessionsKey, jsonEncode(sessionsJson));
  }

  static Future<List<ChatbotSession>> getCachedChatbotSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString(_cachedChatbotSessionsKey);
    if (sessionsJson != null) {
      List<dynamic> data = jsonDecode(sessionsJson);
      return data.map((json) => ChatbotSession.fromJson(json)).toList();
    }
    return [];
  }

  // App State Management
  static Future<void> setLastSync(DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, dateTime.toIso8601String());
  }

  static Future<DateTime?> getLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncStr = prefs.getString(_lastSyncKey);
    if (lastSyncStr != null) {
      return DateTime.parse(lastSyncStr);
    }
    return null;
  }

  static Future<void> setOfflineMode(bool isOffline) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineModeKey, isOffline);
  }

  static Future<bool> isOfflineMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_offlineModeKey) ?? false;
  }

  static Future<void> setOnboardingComplete(bool complete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, complete);
  }

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  // Secure Storage for sensitive data
  static Future<void> saveSecureData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String?> getSecureData(String key) async {
    return await _secureStorage.read(key: key);
  }

  static Future<void> deleteSecureData(String key) async {
    await _secureStorage.delete(key: key);
  }

  // Data synchronization helpers
  static Future<bool> needsSync() async {
    final lastSync = await getLastSync();
    if (lastSync == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    return difference.inHours > 1; // Sync if more than 1 hour old
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secureStorage.deleteAll();
  }

  // Offline lesson completion tracking
  static Future<void> addOfflineProgress(int lessonId, Map<String, dynamic> progressData) async {
    final prefs = await SharedPreferences.getInstance();
    final offlineProgressKey = 'offline_progress_$lessonId';
    await prefs.setString(offlineProgressKey, jsonEncode(progressData));
  }

  static Future<List<Map<String, dynamic>>> getOfflineProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final offlineKeys = keys.where((key) => key.startsWith('offline_progress_'));
    
    List<Map<String, dynamic>> offlineProgress = [];
    for (String key in offlineKeys) {
      final progressJson = prefs.getString(key);
      if (progressJson != null) {
        offlineProgress.add(jsonDecode(progressJson));
      }
    }
    
    return offlineProgress;
  }

  static Future<void> clearOfflineProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final offlineKeys = keys.where((key) => key.startsWith('offline_progress_'));
    
    for (String key in offlineKeys) {
      await prefs.remove(key);
    }
  }
} 