import 'package:equatable/equatable.dart';

enum TransactionDirection { inflow, outflow }

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final String? categoryId;
  final double amount;
  final TransactionDirection direction;
  final DateTime occurredOn;
  final String? note;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.amount,
    required this.direction,
    required this.occurredOn,
    this.note,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        categoryId,
        amount,
        direction,
        occurredOn,
        note,
        createdAt,
      ];

  TransactionEntity copyWith({
    String? id,
    String? userId,
    String? categoryId,
    double? amount,
    TransactionDirection? direction,
    DateTime? occurredOn,
    String? note,
    DateTime? createdAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      direction: direction ?? this.direction,
      occurredOn: occurredOn ?? this.occurredOn,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
