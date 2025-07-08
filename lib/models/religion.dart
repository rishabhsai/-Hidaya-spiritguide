class Religion {
  final int id;
  final String name;
  final String? description;
  final String? iconUrl;
  final bool isActive;
  final DateTime createdAt;

  Religion({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory Religion.fromJson(Map<String, dynamic> json) {
    return Religion(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['icon_url'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 