class ChatbotSession {
  final int id;
  final int userId;
  final String religion;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatbotSession({
    required this.id,
    required this.userId,
    required this.religion,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatbotSession.fromJson(Map<String, dynamic> json) {
    return ChatbotSession(
      id: json['id'],
      userId: json['user_id'],
      religion: json['religion'],
      messages: (json['messages'] as List)
          .map((m) => ChatMessage.fromJson(m))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'religion': religion,
      'messages': messages.map((m) => m.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ChatbotSession copyWith({
    int? id,
    int? userId,
    String? religion,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatbotSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      religion: religion ?? this.religion,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ChatMessage {
  final int id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      isUser: json['is_user'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'is_user': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  ChatMessage copyWith({
    int? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
    );
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