class ChatbotSession {
  final int id;
  final int userId;
  final String? sessionTitle;
  final String initialConcern;
  final String religion;
  final List<ChatMessage>? conversationHistory;
  final String? generatedLesson;
  final List<RecommendedVerse>? recommendedVerses;
  final String? moodImprovement;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatbotSession({
    required this.id,
    required this.userId,
    this.sessionTitle,
    required this.initialConcern,
    required this.religion,
    this.conversationHistory,
    this.generatedLesson,
    this.recommendedVerses,
    this.moodImprovement,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatbotSession.fromJson(Map<String, dynamic> json) {
    return ChatbotSession(
      id: json['id'],
      userId: json['user_id'],
      sessionTitle: json['session_title'],
      initialConcern: json['initial_concern'],
      religion: json['religion'],
      conversationHistory: json['conversation_history'] != null
          ? (json['conversation_history'] as List)
              .map((m) => ChatMessage.fromJson(m))
              .toList()
          : null,
      generatedLesson: json['generated_lesson'],
      recommendedVerses: json['recommended_verses'] != null
          ? (json['recommended_verses'] as List)
              .map((v) => RecommendedVerse.fromJson(v))
              .toList()
          : null,
      moodImprovement: json['mood_improvement'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'session_title': sessionTitle,
      'initial_concern': initialConcern,
      'religion': religion,
      'conversation_history': conversationHistory?.map((m) => m.toJson()).toList(),
      'generated_lesson': generatedLesson,
      'recommended_verses': recommendedVerses?.map((v) => v.toJson()).toList(),
      'mood_improvement': moodImprovement,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({
    required this.role,
    required this.content,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}

class RecommendedVerse {
  final String text;
  final String source;
  final String relevance;

  RecommendedVerse({
    required this.text,
    required this.source,
    required this.relevance,
  });

  factory RecommendedVerse.fromJson(Map<String, dynamic> json) {
    return RecommendedVerse(
      text: json['text'],
      source: json['source'],
      relevance: json['relevance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'source': source,
      'relevance': relevance,
    };
  }
}

class ChatbotResponse {
  final String aiResponse;
  final String? generatedLesson;
  final List<RecommendedVerse>? recommendedVerses;
  final String? moodSuggestion;
  final int sessionId;

  ChatbotResponse({
    required this.aiResponse,
    this.generatedLesson,
    this.recommendedVerses,
    this.moodSuggestion,
    required this.sessionId,
  });

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    return ChatbotResponse(
      aiResponse: json['ai_response'],
      generatedLesson: json['generated_lesson'],
      recommendedVerses: json['recommended_verses'] != null
          ? (json['recommended_verses'] as List)
              .map((v) => RecommendedVerse.fromJson(v))
              .toList()
          : null,
      moodSuggestion: json['mood_suggestion'],
      sessionId: json['session_id'],
    );
  }
} 