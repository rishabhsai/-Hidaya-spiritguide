import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/lesson.dart';
import '../models/progress.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  
  // Onboarding
  static Future<Map<String, dynamic>> postOnboarding(
    String userInput, 
    List<Map<String, dynamic>> conversationHistory
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/onboarding/next_step'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_input': userInput,
          'conversation_history': conversationHistory,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get onboarding response');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // User management
  static Future<User> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create user');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<User> getUser(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
      );

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to get user');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> getUserStats(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/stats'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get user stats');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Lesson management
  static Future<List<Lesson>> getRecommendedLessons(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lessons/recommended/$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> lessonsJson = json.decode(response.body);
        return lessonsJson.map((json) => Lesson.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get recommended lessons');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Lesson> getLesson(int lessonId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lessons/$lessonId'),
      );

      if (response.statusCode == 200) {
        return Lesson.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to get lesson');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Lesson> generateLesson(Map<String, dynamic> requestData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/lessons/generate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        return Lesson.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to generate lesson');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Progress tracking
  static Future<Progress> completeLesson(Map<String, dynamic> progressData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/progress/complete_lesson'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(progressData),
      );

      if (response.statusCode == 200) {
        return Progress.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to complete lesson');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Progress>> getUserProgress(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/progress/$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> progressJson = json.decode(response.body);
        return progressJson.map((json) => Progress.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get user progress');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Sacred texts
  static Future<List<Map<String, dynamic>>> searchSacredTexts(
    String query, 
    String? religion
  ) async {
    try {
      final queryParams = {'query': query};
      if (religion != null) {
        queryParams['religion'] = religion;
      }

      final uri = Uri.parse('$baseUrl/texts/search').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> textsJson = json.decode(response.body);
        return textsJson.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to search sacred texts');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
} 