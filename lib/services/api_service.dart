import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/lesson.dart';
import '../models/progress.dart';
import '../models/religion.dart';
import '../models/course.dart';
import '../models/custom_lesson.dart';
import '../models/chatbot_session.dart';
import 'local_storage_service.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000'; // Change for production

  // Religion endpoints
  static Future<List<Religion>> getReligions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/religions'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        final religions = data.map((json) => Religion.fromJson(json)).toList();
        
        // Cache the data locally
        await LocalStorageService.cacheReligions(religions);
        await LocalStorageService.setLastSync(DateTime.now());
        
        return religions;
      } else {
        throw Exception('Failed to load religions');
      }
    } catch (e) {
      // Fallback to cached data if network fails
      final cachedReligions = await LocalStorageService.getCachedReligions();
      if (cachedReligions.isNotEmpty) {
        await LocalStorageService.setOfflineMode(true);
        return cachedReligions;
      }
      throw Exception('Failed to load religions and no cached data available');
    }
  }

  // Course endpoints
  static Future<List<Course>> getCourses({int? religionId, String? difficulty}) async {
    final queryParams = <String, String>{};
    if (religionId != null) queryParams['religion_id'] = religionId.toString();
    if (difficulty != null) queryParams['difficulty'] = difficulty;

    final uri = Uri.parse('$baseUrl/courses').replace(queryParameters: queryParams);
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Course.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load courses');
    }
  }

  static Future<Course> getCourse(int courseId) async {
    final response = await http.get(Uri.parse('$baseUrl/courses/$courseId'));
    if (response.statusCode == 200) {
      return Course.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load course');
    }
  }

  static Future<List<Chapter>> getCourseChapters(int courseId) async {
    final response = await http.get(Uri.parse('$baseUrl/courses/$courseId/chapters'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Chapter.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chapters');
    }
  }

  static Future<Chapter> getChapter(int chapterId) async {
    final response = await http.get(Uri.parse('$baseUrl/courses/1/chapters/$chapterId'));
    if (response.statusCode == 200) {
      return Chapter.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load chapter');
    }
  }

  static Future<Map<String, dynamic>> generateComprehensiveCourse(String religion, String difficulty) async {
    final response = await http.post(
      Uri.parse('$baseUrl/courses/generate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'religion': religion,
        'difficulty': difficulty,
      }),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to generate course');
    }
  }

  // Custom lesson endpoints
  static Future<CustomLesson> generateCustomLesson(int userId, String topic, String religion, String difficulty) async {
    final response = await http.post(
      Uri.parse('$baseUrl/custom-lessons/generate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'topic': topic,
        'religion': religion,
        'difficulty': difficulty,
      }),
    );
    
    if (response.statusCode == 200) {
      return CustomLesson.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to generate custom lesson');
    }
  }

  static Future<List<CustomLesson>> getUserCustomLessons(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/custom-lessons/$userId'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => CustomLesson.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load custom lessons');
    }
  }

  // Chatbot endpoints
  static Future<ChatbotResponse> startChatbotSession(int userId, String concern, String religion, List<ChatMessage>? conversationHistory) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chatbot/start'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'concern': concern,
        'religion': religion,
        'conversation_history': conversationHistory?.map((m) => m.toJson()).toList(),
      }),
    );
    
    if (response.statusCode == 200) {
      return ChatbotResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to start chatbot session');
    }
  }

  static Future<ChatbotResponse> continueChatbotSession(int sessionId, String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chatbot/$sessionId/continue'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'message': message}),
    );
    
    if (response.statusCode == 200) {
      return ChatbotResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to continue chatbot session');
    }
  }

  static Future<List<ChatbotSession>> getUserChatbotSessions(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/chatbot/$userId/sessions'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChatbotSession.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chatbot sessions');
    }
  }

  // Streak management endpoints
  static Future<Map<String, dynamic>> purchaseStreakSavers(int userId, int quantity) async {
    final response = await http.post(
      Uri.parse('$baseUrl/streak-savers/purchase'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'quantity': quantity,
      }),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to purchase streak savers');
    }
  }

  static Future<Map<String, dynamic>> useStreakSaver(int userId) async {
    final response = await http.post(Uri.parse('$baseUrl/streak-savers/use/$userId'));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to use streak saver');
    }
  }

  static Future<Map<String, dynamic>> updateUserStreak(int userId) async {
    final response = await http.post(Uri.parse('$baseUrl/users/$userId/update-streak'));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update streak');
    }
  }

  // Onboarding endpoints
  static Future<Map<String, dynamic>> getNextOnboardingStep(String userInput, List<Map<String, String>> conversationHistory) async {
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
      throw Exception('Failed to process onboarding step');
    }
  }

  static Future<Map<String, dynamic>> postOnboarding(String userInput, List<Map<String, dynamic>> conversationHistory) async {
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
      throw Exception('Failed to process onboarding step');
    }
  }

  // User endpoints
  static Future<User> createUser(String persona, {String? goals, String? learningStyle, String? religion}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/create'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'persona': persona,
        'goals': goals,
        'learning_style': learningStyle,
        'religion': religion,
      }),
    );
    
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create user');
    }
  }

  static Future<User> getUser(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  static Future<Map<String, dynamic>> getUserStats(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId/stats'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user stats');
    }
  }

  // Lesson endpoints
  static Future<List<Lesson>> getLessons({String? religion, String? difficulty}) async {
    final queryParams = <String, String>{};
    if (religion != null) queryParams['religion'] = religion;
    if (difficulty != null) queryParams['difficulty'] = difficulty;

    final uri = Uri.parse('$baseUrl/lessons').replace(queryParameters: queryParams);
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Lesson.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load lessons');
    }
  }

  static Future<List<Map<String, dynamic>>> getRecommendedLessons(int userId, {int limit = 5}) async {
    final response = await http.get(Uri.parse('$baseUrl/lessons/recommended/$userId?limit=$limit'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load recommended lessons');
    }
  }

  static Future<Lesson> getLesson(int lessonId) async {
    final response = await http.get(Uri.parse('$baseUrl/lessons/$lessonId'));
    if (response.statusCode == 200) {
      return Lesson.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load lesson');
    }
  }

  static Future<Map<String, dynamic>> generateLesson(int userId, {String? topic, String? religion, String difficulty = 'beginner'}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/lessons/generate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'topic': topic,
        'religion': religion,
        'difficulty': difficulty,
      }),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to generate lesson');
    }
  }

  // Progress endpoints
  static Future<Progress> completeLesson(Map<String, dynamic> progressData) async {
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
  }

  static Future<List<Progress>> getUserProgress(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/progress/$userId'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Progress.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user progress');
    }
  }

  // Quiz endpoints
  static Future<Map<String, dynamic>> generateQuiz(String topic, String lessonContent, {String? religion, String difficulty = 'beginner'}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/quizzes/generate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'topic': topic,
        'lesson_content': lessonContent,
        'religion': religion,
        'difficulty': difficulty,
      }),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to generate quiz');
    }
  }
} 