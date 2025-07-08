class CustomLesson {
  final int id;
  final int userId;
  final String topic;
  final String religion;
  final String difficulty;
  final String content;
  final List<String> exercises;
  final List<Map<String, dynamic>> quiz;
  final List<String> quizQuestions; // Simple quiz questions as strings
  final int estimatedTime;
  final DateTime createdAt;

  CustomLesson({
    required this.id,
    required this.userId,
    required this.topic,
    required this.religion,
    required this.difficulty,
    required this.content,
    required this.exercises,
    List<Map<String, dynamic>>? quiz,
    List<String>? quizQuestions,
    required this.estimatedTime,
    required this.createdAt,
  }) : quiz = quiz ?? [],
       quizQuestions = quizQuestions ?? [];

  factory CustomLesson.fromJson(Map<String, dynamic> json) {
    return CustomLesson(
      id: json['id'],
      userId: json['user_id'],
      topic: json['topic'],
      religion: json['religion'],
      difficulty: json['difficulty'],
      content: json['content'],
      exercises: List<String>.from(json['exercises'] ?? []),
      quiz: List<Map<String, dynamic>>.from(json['quiz'] ?? []),
      quizQuestions: List<String>.from(json['quiz_questions'] ?? []),
      estimatedTime: json['estimated_time'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'topic': topic,
      'religion': religion,
      'difficulty': difficulty,
      'content': content,
      'exercises': exercises,
      'quiz': quiz,
      'quiz_questions': quizQuestions,
      'estimated_time': estimatedTime,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CustomLesson copyWith({
    int? id,
    int? userId,
    String? topic,
    String? religion,
    String? difficulty,
    String? content,
    List<String>? exercises,
    List<Map<String, dynamic>>? quiz,
    List<String>? quizQuestions,
    int? estimatedTime,
    DateTime? createdAt,
  }) {
    return CustomLesson(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      topic: topic ?? this.topic,
      religion: religion ?? this.religion,
      difficulty: difficulty ?? this.difficulty,
      content: content ?? this.content,
      exercises: exercises ?? this.exercises,
      quiz: quiz ?? this.quiz,
      quizQuestions: quizQuestions ?? this.quizQuestions,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correct_answer'],
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
    };
  }
}

class PracticalTask {
  final String title;
  final String description;
  final String estimatedTime;

  PracticalTask({
    required this.title,
    required this.description,
    required this.estimatedTime,
  });

  factory PracticalTask.fromJson(Map<String, dynamic> json) {
    return PracticalTask(
      title: json['title'],
      description: json['description'],
      estimatedTime: json['estimated_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'estimated_time': estimatedTime,
    };
  }
}

class Source {
  final String title;
  final String url;
  final String type;

  Source({
    required this.title,
    required this.url,
    required this.type,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      title: json['title'],
      url: json['url'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'type': type,
    };
  }
} 