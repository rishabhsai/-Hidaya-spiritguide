import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../models/progress.dart';
import '../services/api_service.dart';

class LessonProvider with ChangeNotifier {
  List<Lesson> _lessons = [];
  Progress? _userProgress;
  String? _error;
  bool _isLoading = false;

  List<Lesson> get lessons => _lessons;
  Progress? get userProgress => _userProgress;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> fetchLessons({String? religion}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lessons = await ApiService.getLessons(religion: religion);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserProgress(int userId) async {
    try {
      _userProgress = await ApiService.getProgress(userId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> completeLesson(int userId, int lessonId) async {
    try {
      await ApiService.completeLesson(userId, lessonId);
      // Refresh progress after completing lesson
      await fetchUserProgress(userId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 