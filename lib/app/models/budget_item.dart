import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final String id;
  final String name;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  const Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, amount, startDate, endDate, createdAt];

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      createdAt: DateTime.parse(json['created_at']),
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
    };
  }
}
