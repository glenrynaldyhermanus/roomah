import 'package:equatable/equatable.dart';

class Routine extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? categoryId;
  final String frequencyType;
  final int frequencyValue;
  final DateTime? lastCompletedAt;
  final DateTime nextDueDate;
  final bool isActive;
  final DateTime createdAt;

  const Routine({
    required this.id,
    required this.title,
    this.description,
    this.categoryId,
    required this.frequencyType,
    required this.frequencyValue,
    this.lastCompletedAt,
    required this.nextDueDate,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        categoryId,
        frequencyType,
        frequencyValue,
        lastCompletedAt,
        nextDueDate,
        isActive,
        createdAt,
      ];

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      categoryId: json['category_id'],
      frequencyType: json['frequency_type'],
      frequencyValue: json['frequency_value'],
      lastCompletedAt: json['last_completed_at'] == null
          ? null
          : DateTime.parse(json['last_completed_at']),
      nextDueDate: DateTime.parse(json['next_due_date']),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'frequency_type': frequencyType,
      'frequency_value': frequencyValue,
      'last_completed_at': lastCompletedAt?.toIso8601String(),
      'next_due_date': nextDueDate.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Routine copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    String? frequencyType,
    int? frequencyValue,
    DateTime? lastCompletedAt,
    DateTime? nextDueDate,
    bool? isActive,
    DateTime? createdAt,
    bool? clearLastCompletedAt,
  }) {
    return Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      frequencyType: frequencyType ?? this.frequencyType,
      frequencyValue: frequencyValue ?? this.frequencyValue,
      lastCompletedAt: clearLastCompletedAt == true
          ? null
          : (lastCompletedAt ?? this.lastCompletedAt),
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 