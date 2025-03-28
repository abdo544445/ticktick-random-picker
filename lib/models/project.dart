class Project {
  final String id;
  final String name;
  final String color;
  final bool closed;
  final DateTime modifiedTime;

  Project({
    required this.id,
    required this.name,
    required this.color,
    required this.closed,
    required this.modifiedTime,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      color: json['color'] ?? '#808080',
      closed: json['closed'] ?? false,
      modifiedTime: DateTime.parse(json['modifiedTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'closed': closed,
      'modifiedTime': modifiedTime.toIso8601String(),
    };
  }
} 