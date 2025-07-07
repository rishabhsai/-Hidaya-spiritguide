import 'package:flutter/foundation.dart';
import '../models/lesson.dart';
import '../models/progress.dart';
import '../services/api_service.dart';

class LessonProvider with ChangeNotifier {
  List<Lesson> _recommendedLessons = [];
  List<Progress> _userProgress = [];
  bool _isLoading = false;
  String? _error;

  List<Lesson> get recommendedLessons => _recommendedLessons;
  List<Progress> get userProgress => _userProgress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRecommendedLessons(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recommendedLessons = await ApiService.getRecommendedLessons(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserProgress(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userProgress = await ApiService.getUserProgress(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Lesson?> getLesson(int lessonId) async {
    try {
      return await ApiService.getLesson(lessonId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Lesson?> generateLesson(Map<String, dynamic> requestData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final lesson = await ApiService.generateLesson(requestData);
      _recommendedLessons.insert(0, lesson); // Add to beginning of list
      return lesson;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeLesson(Map<String, dynamic> progressData) async {
    try {
      final progress = await ApiService.completeLesson(progressData);
      _userProgress.add(progress);
      
      // Remove from recommended lessons if it was there
      _recommendedLessons.removeWhere((lesson) => lesson.id == progress.lessonId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  bool isLessonCompleted(int lessonId) {
    return _userProgress.any((progress) => progress.lessonId == lessonId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 