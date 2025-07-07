class Progress {
  final int id;
  final int userId;
  final int lessonId;
  final DateTime completedAt;
  final String? reflection;
  final int? rating;

  Progress({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.completedAt,
    this.reflection,
    this.rating,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['id'],
      userId: json['user_id'],
      lessonId: json['lesson_id'],
      completedAt: DateTime.parse(json['completed_at']),
      reflection: json['reflection'],
      rating: json['rating'],
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
    };
  }
} 