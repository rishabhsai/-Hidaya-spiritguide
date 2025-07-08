class User {
  final int id;
  final String persona;
  final String? goals;
  final String? learningStyle;
  final String? religion;
  final int currentStreak;
  final int totalLessonsCompleted;
  final int totalTimeSpent;
  final DateTime createdAt;

  User({
    required this.id,
    required this.persona,
    this.goals,
    this.learningStyle,
    this.religion,
    this.currentStreak = 0,
    this.totalLessonsCompleted = 0,
    this.totalTimeSpent = 0,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      persona: json['persona'],
      goals: json['goals'],
      learningStyle: json['learning_style'],
      religion: json['religion'],
      currentStreak: json['current_streak'] ?? 0,
      totalLessonsCompleted: json['total_lessons_completed'] ?? 0,
      totalTimeSpent: json['total_time_spent'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'persona': persona,
      'goals': goals,
      'learning_style': learningStyle,
      'religion': religion,
      'current_streak': currentStreak,
      'total_lessons_completed': totalLessonsCompleted,
      'total_time_spent': totalTimeSpent,
      'created_at': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? persona,
    String? goals,
    String? learningStyle,
    String? religion,
    int? currentStreak,
    int? totalLessonsCompleted,
    int? totalTimeSpent,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      persona: persona ?? this.persona,
      goals: goals ?? this.goals,
      learningStyle: learningStyle ?? this.learningStyle,
      religion: religion ?? this.religion,
      currentStreak: currentStreak ?? this.currentStreak,
      totalLessonsCompleted: totalLessonsCompleted ?? this.totalLessonsCompleted,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UserStats {
  final int completedLessons;
  final int currentStreak;
  final int totalTimeSpent;
  final double? averageRating;
  final String? favoriteReligion;
  final int learningStreak;

  UserStats({
    required this.completedLessons,
    required this.currentStreak,
    required this.totalTimeSpent,
    this.averageRating,
    this.favoriteReligion,
    this.learningStreak = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      completedLessons: json['completed_lessons'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      totalTimeSpent: json['total_time_spent'] ?? 0,
      averageRating: json['average_rating']?.toDouble(),
      favoriteReligion: json['favorite_religion'],
      learningStreak: json['learning_streak'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed_lessons': completedLessons,
      'current_streak': currentStreak,
      'total_time_spent': totalTimeSpent,
      'average_rating': averageRating,
      'favorite_religion': favoriteReligion,
      'learning_streak': learningStreak,
    };
  }
} 