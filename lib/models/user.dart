class User {
  final int id;
  final String persona;
  final String? goals;
  final String? learningStyle;
  final String? religion;
  final DateTime createdAt;

  User({
    required this.id,
    required this.persona,
    this.goals,
    this.learningStyle,
    this.religion,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      persona: json['persona'],
      goals: json['goals'],
      learningStyle: json['learning_style'],
      religion: json['religion'],
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
      'created_at': createdAt.toIso8601String(),
    };
  }
} 