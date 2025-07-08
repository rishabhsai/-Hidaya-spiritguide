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

  static Future<User> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update user');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<UserStats> getUserStats(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/stats'),
      );

      if (response.statusCode == 200) {
        return UserStats.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to get user stats');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> getUserProgressSummary(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/progress-summary'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get user progress summary');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Reflection>> getUserReflections(int userId, {int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/reflections?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> reflectionsJson = json.decode(response.body);
        return reflectionsJson.map((json) => Reflection.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get user reflections');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Reflection> createUserReflection(int userId, Map<String, dynamic> reflectionData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$userId/reflections'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reflectionData),
      );

      if (response.statusCode == 200) {
        return Reflection.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create reflection');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Lesson management
  static Future<List<Lesson>> getAllLessons({String? religion, String? difficulty}) async {
    try {
      final queryParams = <String, String>{};
      if (religion != null) queryParams['religion'] = religion;
      if (difficulty != null) queryParams['difficulty'] = difficulty;

      final uri = Uri.parse('$baseUrl/lessons').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> lessonsJson = json.decode(response.body);
        return lessonsJson.map((json) => Lesson.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get lessons');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<LessonRecommendation>> getRecommendedLessons(int userId, {int limit = 5}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lessons/recommended/$userId?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> recommendationsJson = json.decode(response.body);
        return recommendationsJson.map((json) => LessonRecommendation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get recommended lessons');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<LessonWithCompletion>> getLessonsByReligion(String religion, {int? userId}) async {
    try {
      final queryParams = <String, String>{};
      if (userId != null) queryParams['user_id'] = userId.toString();

      final uri = Uri.parse('$baseUrl/lessons/religion/$religion').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> lessonsJson = json.decode(response.body);
        return lessonsJson.map((json) => LessonWithCompletion.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get lessons by religion');
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

  static Future<Lesson?> getNextLesson(int userId, int lessonId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lessons/$lessonId/next/$userId'),
      );

      if (response.statusCode == 200) {
        return Lesson.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null; // No next lesson found
      } else {
        throw Exception('Failed to get next lesson');
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

  static Future<List<Lesson>> searchLessons(String query, {String? religion}) async {
    try {
      final queryParams = {'query': query};
      if (religion != null) queryParams['religion'] = religion;

      final uri = Uri.parse('$baseUrl/lessons/search').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> lessonsJson = json.decode(response.body);
        return lessonsJson.map((json) => Lesson.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search lessons');
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

  static Future<Map<String, dynamic>> getLessonProgress(int userId, int lessonId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/progress/$userId/lesson/$lessonId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get lesson progress');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<ProgressStats> getUserLessonStats(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/progress/$userId/stats'),
      );

      if (response.statusCode == 200) {
        return ProgressStats.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to get user lesson stats');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Reflection management
  static Future<Reflection> createReflection(Map<String, dynamic> reflectionData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reflections'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reflectionData),
      );

      if (response.statusCode == 200) {
        return Reflection.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create reflection');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Reflection>> getLessonReflections(int lessonId, {int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reflections/lesson/$lessonId?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> reflectionsJson = json.decode(response.body);
        return reflectionsJson.map((json) => Reflection.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get lesson reflections');
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

  static Future<List<Map<String, dynamic>>> getSacredTexts({String? religion, String? book}) async {
    try {
      final queryParams = <String, String>{};
      if (religion != null) queryParams['religion'] = religion;
      if (book != null) queryParams['book'] = book;

      final uri = Uri.parse('$baseUrl/texts').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> textsJson = json.decode(response.body);
        return textsJson.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get sacred texts');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // AI endpoints
  static Future<String> generateReflectionPrompt(int userId, int lessonId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/reflection-prompt'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'lesson_id': lessonId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['prompt'];
      } else {
        throw Exception('Failed to generate reflection prompt');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
} 