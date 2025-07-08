class Chapter {
  final int id;
  final int courseId;
  final String title;
  final String content;
  final String category;
  final String difficulty;
  final int estimatedTime;
  final bool isCompleted;
  final int order;
  final DateTime createdAt;

  Chapter({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    required this.category,
    required this.difficulty,
    required this.estimatedTime,
    required this.isCompleted,
    required this.order,
    required this.createdAt,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      courseId: json['course_id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      difficulty: json['difficulty'],
      estimatedTime: json['estimated_time'],
      isCompleted: json['is_completed'] ?? false,
      order: json['order'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'content': content,
      'category': category,
      'difficulty': difficulty,
      'estimated_time': estimatedTime,
      'is_completed': isCompleted,
      'order': order,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Chapter copyWith({
    int? id,
    int? courseId,
    String? title,
    String? content,
    String? category,
    String? difficulty,
    int? estimatedTime,
    bool? isCompleted,
    int? order,
    DateTime? createdAt,
  }) {
    return Chapter(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 