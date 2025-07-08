import 'lesson.dart';

class Progress {
  final int id;
  final int userId;
  final int lessonId;
  final DateTime completedAt;
  final String? reflection;
  final int? rating;
  final int? timeSpent;
  final String? moodBefore;
  final String? moodAfter;
  final Lesson? lesson;

  Progress({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.completedAt,
    this.reflection,
    this.rating,
    this.timeSpent,
    this.moodBefore,
    this.moodAfter,
    this.lesson,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['id'],
      userId: json['user_id'],
      lessonId: json['lesson_id'],
      completedAt: DateTime.parse(json['completed_at']),
      reflection: json['reflection'],
      rating: json['rating'],
      timeSpent: json['time_spent'],
      moodBefore: json['mood_before'],
      moodAfter: json['mood_after'],
      lesson: json['lesson'] != null ? Lesson.fromJson(json['lesson']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'lesson_id': lessonId,
      'completed_at': completedAt.toIso8601String(),
      'reflection': reflection,
      'rating': rating,
      'time_spent': timeSpent,
      'mood_before': moodBefore,
      'mood_after': moodAfter,
      'lesson': lesson?.toJson(),
    };
  }

  Progress copyWith({
    int? id,
    int? userId,
    int? lessonId,
    DateTime? completedAt,
    String? reflection,
    int? rating,
    int? timeSpent,
    String? moodBefore,
    String? moodAfter,
    Lesson? lesson,
  }) {
    return Progress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      completedAt: completedAt ?? this.completedAt,
      reflection: reflection ?? this.reflection,
      rating: rating ?? this.rating,
      timeSpent: timeSpent ?? this.timeSpent,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      lesson: lesson ?? this.lesson,
    );
  }
}

class Reflection {
  final int id;
  final int userId;
  final int? lessonId;
  final String reflectionText;
  final String? mood;
  final DateTime createdAt;

  Reflection({
    required this.id,
    required this.userId,
    this.lessonId,
    required this.reflectionText,
    this.mood,
    required this.createdAt,
  });

  factory Reflection.fromJson(Map<String, dynamic> json) {
    return Reflection(
      id: json['id'],
      userId: json['user_id'],
      lessonId: json['lesson_id'],
      reflectionText: json['reflection_text'],
      mood: json['mood'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'lesson_id': lessonId,
      'reflection_text': reflectionText,
      'mood': mood,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ProgressStats {
  final int totalCompleted;
  final double? averageRating;
  final int totalTimeSpent;
  final List<ReligionStats> religionBreakdown;
  final List<DifficultyStats> difficultyBreakdown;

  ProgressStats({
    required this.totalCompleted,
    this.averageRating,
    required this.totalTimeSpent,
    required this.religionBreakdown,
    required this.difficultyBreakdown,
  });

  factory ProgressStats.fromJson(Map<String, dynamic> json) {
    return ProgressStats(
      totalCompleted: json['total_completed'] ?? 0,
      averageRating: json['average_rating']?.toDouble(),
      totalTimeSpent: json['total_time_spent'] ?? 0,
      religionBreakdown: (json['religion_breakdown'] as List?)
          ?.map((e) => ReligionStats.fromJson(e))
          .toList() ?? [],
      difficultyBreakdown: (json['difficulty_breakdown'] as List?)
          ?.map((e) => DifficultyStats.fromJson(e))
          .toList() ?? [],
    );
  }
}

class ReligionStats {
  final String religion;
  final int count;
  final double? avgRating;

  ReligionStats({
    required this.religion,
    required this.count,
    this.avgRating,
  });

  factory ReligionStats.fromJson(Map<String, dynamic> json) {
    return ReligionStats(
      religion: json['religion'],
      count: json['count'],
      avgRating: json['avg_rating']?.toDouble(),
    );
  }
}

class DifficultyStats {
  final String difficulty;
  final int count;

  DifficultyStats({
    required this.difficulty,
    required this.count,
  });

  factory DifficultyStats.fromJson(Map<String, dynamic> json) {
    return DifficultyStats(
      difficulty: json['difficulty'],
      count: json['count'],
    );
  }
}

class ProgressCreate {
  final int userId;
  final int lessonId;
  final String? reflection;
  final int? rating;
  final int? timeSpent;
  final String? moodBefore;
  final String? moodAfter;

  ProgressCreate({
    required this.userId,
    required this.lessonId,
    this.reflection,
    this.rating,
    this.timeSpent,
    this.moodBefore,
    this.moodAfter,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'lesson_id': lessonId,
      'reflection': reflection,
      'rating': rating,
      'time_spent': timeSpent,
      'mood_before': moodBefore,
      'mood_after': moodAfter,
    };
  }
} 