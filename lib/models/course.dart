class Course {
  final int id;
  final int religionId;
  final String name;
  final String? description;
  final String difficulty;
  final int totalChapters;
  final int estimatedHours;
  final bool isComprehensive;
  final DateTime createdAt;

  Course({
    required this.id,
    required this.religionId,
    required this.name,
    this.description,
    required this.difficulty,
    required this.totalChapters,
    required this.estimatedHours,
    required this.isComprehensive,
    required this.createdAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      religionId: json['religion_id'],
      name: json['name'],
      description: json['description'],
      difficulty: json['difficulty'],
      totalChapters: json['total_chapters'] ?? 0,
      estimatedHours: json['estimated_hours'] ?? 0,
      isComprehensive: json['is_comprehensive'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'religion_id': religionId,
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'total_chapters': totalChapters,
      'estimated_hours': estimatedHours,
      'is_comprehensive': isComprehensive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Chapter {
  final int id;
  final int courseId;
  final String title;
  final String content;
  final int chapterNumber;
  final int duration;
  final String? learningObjectives;
  final String? prerequisites;
  final DateTime createdAt;

  Chapter({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    required this.chapterNumber,
    required this.duration,
    this.learningObjectives,
    this.prerequisites,
    required this.createdAt,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      courseId: json['course_id'],
      title: json['title'],
      content: json['content'],
      chapterNumber: json['chapter_number'],
      duration: json['duration'],
      learningObjectives: json['learning_objectives'],
      prerequisites: json['prerequisites'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'content': content,
      'chapter_number': chapterNumber,
      'duration': duration,
      'learning_objectives': learningObjectives,
      'prerequisites': prerequisites,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 