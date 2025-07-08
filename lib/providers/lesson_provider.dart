import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../models/progress.dart';
import '../services/api_service.dart';

class LessonProvider with ChangeNotifier {
  List<Lesson> _recommendedLessons = [];
  List<Progress> _completedLessons = [];
  String? _error;
  bool _isLoading = false;

  List<Lesson> get recommendedLessons => _recommendedLessons;
  List<Progress> get completedLessons => _completedLessons;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> fetchRecommendedLessons(int userId) async {
    final lessons = await ApiService.getRecommendedLessons(userId);
    _recommendedLessons = lessons;
    notifyListeners();
  }

  Future<Lesson?> generateLesson(int userId) async {
    final lesson = await ApiService.generateLesson(userId);
    if (lesson != null) {
      _recommendedLessons.insert(0, lesson);
      notifyListeners();
    }
    return lesson;
  }

  Future<bool> completeLesson(Map<String, dynamic> progressData) async {
    try {
      final progress = await ApiService.completeLesson(progressData);
      _completedLessons.add(progress);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
} 