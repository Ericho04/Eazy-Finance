enum TransactionType { income, expense }
enum TransactionSource { manual, ocr, bank }

class Transaction {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final String description;
  final String date;
  final TransactionType type;
  final TransactionSource source;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.type,
    required this.source,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Transaction copyWith({
    String? id,
    String? userId,
    double? amount,
    String? category,
    String? description,
    String? date,
    TransactionType? type,
    TransactionSource? source,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date,
      'type': type.toString().split('.').last,
      'source': source.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['userId'],
      amount: json['amount'].toDouble(),
      category: json['category'],
      description: json['description'],
      date: json['date'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      source: TransactionSource.values.firstWhere(
        (e) => e.toString().split('.').last == json['source'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}