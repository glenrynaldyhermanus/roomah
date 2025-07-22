import 'package:equatable/equatable.dart';

class RoutineCategory extends Equatable {
  final String id;
  final String name;
  final String color;
  final String? icon;
  final DateTime createdAt;

  const RoutineCategory({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, color, icon, createdAt];

  factory RoutineCategory.fromJson(Map<String, dynamic> json) {
    return RoutineCategory(
      id: json['id'],
      name: json['name'],
      color: json['color'] ?? '#3B82F6',
      icon: json['icon'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
    };
  }

  RoutineCategory copyWith({
    String? id,
    String? name,
    String? color,
    String? icon,
    DateTime? createdAt,
  }) {
    return RoutineCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 