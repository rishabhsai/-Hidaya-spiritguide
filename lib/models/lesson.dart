class Lesson {
  final int id;
  final String title;
  final String content;
  final String religion;
  final String difficulty;
  final int duration;
  final String? practicalTask;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.religion,
    required this.difficulty,
    required this.duration,
    this.practicalTask,
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
    };
  }
} 