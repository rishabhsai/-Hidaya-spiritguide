class Lesson {
  final int id;
  final String title;
  final String content;
  final String religion;
  final String difficulty;
  final int duration;
  final String? practicalTask;
  final String? learningObjectives;
  final String? prerequisites;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.religion,
    required this.difficulty,
    required this.duration,
    this.practicalTask,
    this.learningObjectives,
    this.prerequisites,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      religion: json['religion'],
      difficulty: json['difficulty'],
      duration: json['duration'],
      practicalTask: json['practical_task'],
      learningObjectives: json['learning_objectives'],
      prerequisites: json['prerequisites'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'religion': religion,
      'difficulty': difficulty,
      'duration': duration,
      'practical_task': practicalTask,
      'learning_objectives': learningObjectives,
      'prerequisites': prerequisites,
    };
  }

  Lesson copyWith({
    int? id,
    String? title,
    String? content,
    String? religion,
    String? difficulty,
    int? duration,
    String? practicalTask,
    String? learningObjectives,
    String? prerequisites,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      religion: religion ?? this.religion,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      practicalTask: practicalTask ?? this.practicalTask,
      learningObjectives: learningObjectives ?? this.learningObjectives,
      prerequisites: prerequisites ?? this.prerequisites,
    );
  }
}

class LessonRecommendation {
  final Lesson lesson;
  final String reason;
  final double confidence;

  LessonRecommendation({
    required this.lesson,
    required this.reason,
    required this.confidence,
  });

  factory LessonRecommendation.fromJson(Map<String, dynamic> json) {
    return LessonRecommendation(
      lesson: Lesson.fromJson(json['lesson']),
      reason: json['reason'],
      confidence: json['confidence']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lesson': lesson.toJson(),
      'reason': reason,
      'confidence': confidence,
    };
  }
}

class LessonWithCompletion {
  final Lesson lesson;
  final bool completed;

  LessonWithCompletion({
    required this.lesson,
    required this.completed,
  });

  factory LessonWithCompletion.fromJson(Map<String, dynamic> json) {
    return LessonWithCompletion(
      lesson: Lesson.fromJson(json['lesson']),
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lesson': lesson.toJson(),
      'completed': completed,
    };
  }
} 