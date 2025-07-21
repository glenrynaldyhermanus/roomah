import 'package:equatable/equatable.dart';

class Finance extends Equatable {
  final String id;
  final String name;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final String? createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final DateTime? deletedAt;
  final String? deletedBy;

  const Finance({
    required this.id,
    required this.name,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.deletedAt,
    this.deletedBy,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        startDate,
        endDate,
        createdAt,
        createdBy,
        updatedAt,
        updatedBy,
        deletedAt,
        deletedBy,
      ];

  factory Finance.fromJson(Map<String, dynamic> json) {
    return Finance(
      id: json['id'],
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      updatedBy: json['updated_by'],
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      deletedBy: json['deleted_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'updated_at': updatedAt?.toIso8601String(),
      'updated_by': updatedBy,
      'deleted_at': deletedAt?.toIso8601String(),
      'deleted_by': deletedBy,
    };
  }
} 