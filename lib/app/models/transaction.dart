import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final double amount;
  final String type;
  final String? description;
  final DateTime transactionDate;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    this.description,
    required this.transactionDate,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, amount, type, description, transactionDate, createdAt];

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'],
      description: json['description'],
      transactionDate: DateTime.parse(json['transaction_date']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'description': description,
      'transaction_date': transactionDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
