// ✅ FIXED: transaction.dart - 使用 snake_case 匹配 Supabase 数据库
enum TransactionType { income, expense }
enum TransactionSource { manual, ocr, bank }

class Transaction {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final String description;
  final String date;  // 这在Dart中保持为date，但会映射到数据库的transaction_date
  final TransactionType type;
  final TransactionSource source;
  final DateTime createdAt;
  final DateTime? updatedAt;

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
    this.updatedAt,
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
    DateTime? updatedAt,
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
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ✅ 修复：toJson 使用 snake_case
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,  // ✅ snake_case
      'amount': amount,
      'category': category,
      'description': description,
      'transaction_date': date,  // ✅ 映射到数据库的 transaction_date
      'type': type.toString().split('.').last,
      'source': source.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),  // ✅ snake_case
      'updated_at': updatedAt?.toIso8601String(),  // ✅ snake_case
    };
  }

  // ✅ 修复：fromJson 读取 snake_case
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,  // ✅ snake_case
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String,
      // ✅ 处理两种可能的字段名（向后兼容）
      date: (json['transaction_date'] ?? json['date']) as String,
      type: TransactionType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'],
        orElse: () => TransactionType.expense,
      ),
      source: TransactionSource.values.firstWhere(
            (e) => e.toString().split('.').last == json['source'],
        orElse: () => TransactionSource.manual,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),  // ✅ snake_case
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,  // ✅ snake_case
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, category: $category, type: $type, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Transaction categories
class TransactionCategory {
  // Expense categories
  static const String food = 'Food & Dining';
  static const String transportation = 'Transportation';
  static const String shopping = 'Shopping';
  static const String entertainment = 'Entertainment';
  static const String bills = 'Bills & Utilities';
  static const String healthcare = 'Healthcare';
  static const String education = 'Education';
  static const String travel = 'Travel';
  static const String groceries = 'Groceries';
  static const String other = 'Other';

  // Income categories
  static const String salary = 'Salary';
  static const String business = 'Business';
  static const String investment = 'Investment';
  static const String freelance = 'Freelance';
  static const String gift = 'Gift';

  static List<String> get expenseCategories => [
    food,
    transportation,
    shopping,
    entertainment,
    bills,
    healthcare,
    education,
    travel,
    groceries,
    other,
  ];

  static List<String> get incomeCategories => [
    salary,
    business,
    investment,
    freelance,
    gift,
    other,
  ];

  static Map<String, String> get categoryEmojis => {
    food: '🍽️',
    transportation: '🚗',
    shopping: '🛍️',
    entertainment: '🎬',
    bills: '💡',
    healthcare: '⚕️',
    education: '📚',
    travel: '✈️',
    groceries: '🛒',
    salary: '💼',
    business: '🏢',
    investment: '📈',
    freelance: '💻',
    gift: '🎁',
    other: '📦',
  };

  static String getCategoryEmoji(String category) {
    return categoryEmojis[category] ?? '💳';
  }
}