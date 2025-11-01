class Budget {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final String period; // 'monthly', 'weekly', 'daily'
  final bool isActive;
  final DateTime createdAt;

  Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.period,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Budget copyWith({
    String? id,
    String? userId,
    String? category,
    double? amount,
    String? period,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'amount': amount,
      'period': period,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      userId: json['userId'],
      category: json['category'],
      amount: json['amount'].toDouble(),
      period: json['period'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}