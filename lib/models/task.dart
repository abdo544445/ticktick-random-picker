class Task {
  final String id;
  final String title;
  final String projectId;
  final String? content;
  final DateTime? dueDate;
  final bool isCompleted;
  final List<String>? tags;
  final int priority;
  final DateTime createdTime;

  Task({
    required this.id,
    required this.title,
    required this.projectId,
    this.content,
    this.dueDate,
    required this.isCompleted,
    this.tags,
    required this.priority,
    required this.createdTime,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      projectId: json['projectId'],
      content: json['content'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isCompleted: json['status'] == 'completed',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      priority: json['priority'] ?? 0,
      createdTime: DateTime.parse(json['createdTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'projectId': projectId,
      'content': content,
      'dueDate': dueDate?.toIso8601String(),
      'status': isCompleted ? 'completed' : 'normal',
      'tags': tags,
      'priority': priority,
      'createdTime': createdTime.toIso8601String(),
    };
  }
} 