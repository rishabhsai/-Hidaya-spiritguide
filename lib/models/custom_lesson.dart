class CustomLesson {
  final int id;
  final int userId;
  final String title;
  final String topic;
  final String religion;
  final String content;
  final List<QuizQuestion>? quizQuestions;
  final List<PracticalTask>? practicalTasks;
  final List<Source>? sources;
  final DateTime createdAt;

  CustomLesson({
    required this.id,
    required this.userId,
    required this.title,
    required this.topic,
    required this.religion,
    required this.content,
    this.quizQuestions,
    this.practicalTasks,
    this.sources,
    required this.createdAt,
  });

  factory CustomLesson.fromJson(Map<String, dynamic> json) {
    return CustomLesson(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      topic: json['topic'],
      religion: json['religion'],
      content: json['content'],
      quizQuestions: json['quiz_questions'] != null
          ? (json['quiz_questions'] as List)
              .map((q) => QuizQuestion.fromJson(q))
              .toList()
          : null,
      practicalTasks: json['practical_tasks'] != null
          ? (json['practical_tasks'] as List)
              .map((t) => PracticalTask.fromJson(t))
              .toList()
          : null,
      sources: json['sources'] != null
          ? (json['sources'] as List)
              .map((s) => Source.fromJson(s))
              .toList()
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'topic': topic,
      'religion': religion,
      'content': content,
      'quiz_questions': quizQuestions?.map((q) => q.toJson()).toList(),
      'practical_tasks': practicalTasks?.map((t) => t.toJson()).toList(),
      'sources': sources?.map((s) => s.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
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