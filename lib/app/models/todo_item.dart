import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? dueDate;
  final int priority;

  const Todo({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
    this.dueDate,
    this.priority = 0,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    isCompleted,
    createdAt,
    completedAt,
    dueDate,
    priority,
  ];

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['is_completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] == null ? null : DateTime.parse(json['completed_at']),
      dueDate: json['due_date'] == null ? null : DateTime.parse(json['due_date']),
      priority: (json['priority'] ?? 0) is int ? (json['priority'] ?? 0) : int.tryParse(json['priority'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'priority': priority,
    };
  }

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? clearCompletedAt,
    DateTime? dueDate,
    bool? clearDueDate,
    int? priority,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt == true ? null : (completedAt ?? this.completedAt),
      dueDate: clearDueDate == true ? null : (dueDate ?? this.dueDate),
      priority: priority ?? this.priority,
    );
  }
}
