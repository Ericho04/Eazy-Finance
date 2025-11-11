// ✅ financial_debt.dart - 基于 Supabase financial_debts 表

enum DebtType {
  creditCard,      // credit_card in DB
  personalLoan,    // personal_loan in DB
  carLoan,         // car_loan in DB
  homeLoan,        // home_loan in DB
  studentLoan,     // student_loan in DB
  businessLoan,    // business_loan in DB
  other,
}

class FinancialDebt {
  final String id;
  final String userId;
  final String debtName;
  final DebtType debtType;
  final double originalAmount;
  final double currentBalance;
  final double interestRate;
  final double minimumPayment;
  final DateTime? dueDate;
  final String creditorName;
  final DateTime? lastPaymentDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FinancialDebt({
    required this.id,
    required this.userId,
    required this.debtName,
    required this.debtType,
    required this.originalAmount,
    required this.currentBalance,
    this.interestRate = 0.0,
    this.minimumPayment = 0.0,
    this.dueDate,
    required this.creditorName,
    this.lastPaymentDate,
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Calculate remaining percentage
  double get remainingPercentage {
    if (originalAmount <= 0) return 0.0;
    return (currentBalance / originalAmount) * 100;
  }

  // Calculate paid percentage
  double get paidPercentage {
    if (originalAmount <= 0) return 0.0;
    return ((originalAmount - currentBalance) / originalAmount) * 100;
  }

  // Calculate paid amount
  double get paidAmount {
    return originalAmount - currentBalance;
  }

  // Check if payment is overdue
  bool get isOverdue {
    if (dueDate == null || !isActive) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  // Days until due date
  int? get daysUntilDue {
    if (dueDate == null) return null;
    final difference = dueDate!.difference(DateTime.now()).inDays;
    return difference < 0 ? 0 : difference;
  }

  // Copy with method
  FinancialDebt copyWith({
    String? id,
    String? userId,
    String? debtName,
    DebtType? debtType,
    double? originalAmount,
    double? currentBalance,
    double? interestRate,
    double? minimumPayment,
    DateTime? dueDate,
    String? creditorName,
    DateTime? lastPaymentDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinancialDebt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      debtName: debtName ?? this.debtName,
      debtType: debtType ?? this.debtType,
      originalAmount: originalAmount ?? this.originalAmount,
      currentBalance: currentBalance ?? this.currentBalance,
      interestRate: interestRate ?? this.interestRate,
      minimumPayment: minimumPayment ?? this.minimumPayment,
      dueDate: dueDate ?? this.dueDate,
      creditorName: creditorName ?? this.creditorName,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Make a payment
  FinancialDebt makePayment(double amount) {
    final newBalance = currentBalance - amount;
    return copyWith(
      currentBalance: newBalance < 0 ? 0 : newBalance,
      lastPaymentDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // ✅ toJson 使用 snake_case
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,  // ✅ snake_case
      'debt_name': debtName,  // ✅ snake_case
      'debt_type': _debtTypeToString(debtType),  // ✅ snake_case
      'original_amount': originalAmount,  // ✅ snake_case
      'current_balance': currentBalance,  // ✅ snake_case
      'interest_rate': interestRate,  // ✅ snake_case
      'minimum_payment': minimumPayment,  // ✅ snake_case
      'due_date': dueDate?.toIso8601String(),  // ✅ snake_case
      'creditor_name': creditorName,  // ✅ snake_case
      'last_payment_date': lastPaymentDate?.toIso8601String(),  // ✅ snake_case
      'is_active': isActive,  // ✅ snake_case
      'created_at': createdAt.toIso8601String(),  // ✅ snake_case
      'updated_at': updatedAt?.toIso8601String(),  // ✅ snake_case
    };
  }

  // ✅ fromJson 读取 snake_case
  factory FinancialDebt.fromJson(Map<String, dynamic> json) {
    return FinancialDebt(
      id: json['id'] as String,
      userId: json['user_id'] as String,  // ✅ snake_case
      debtName: json['debt_name'] as String,  // ✅ snake_case
      debtType: _stringToDebtType(json['debt_type'] as String),  // ✅ snake_case
      originalAmount: (json['original_amount'] as num).toDouble(),  // ✅ snake_case
      currentBalance: (json['current_balance'] as num).toDouble(),  // ✅ snake_case
      interestRate: (json['interest_rate'] as num?)?.toDouble() ?? 0.0,  // ✅ snake_case
      minimumPayment: (json['minimum_payment'] as num?)?.toDouble() ?? 0.0,  // ✅ snake_case
      dueDate: json['due_date'] != null  // ✅ snake_case
          ? DateTime.parse(json['due_date'] as String)
          : null,
      creditorName: json['creditor_name'] as String,  // ✅ snake_case
      lastPaymentDate: json['last_payment_date'] != null  // ✅ snake_case
          ? DateTime.parse(json['last_payment_date'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,  // ✅ snake_case
      createdAt: DateTime.parse(json['created_at'] as String),  // ✅ snake_case
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,  // ✅ snake_case
    );
  }

  // Helper: Convert DebtType to database string
  static String _debtTypeToString(DebtType type) {
    switch (type) {
      case DebtType.creditCard:
        return 'credit_card';  // ✅ snake_case
      case DebtType.personalLoan:
        return 'personal_loan';  // ✅ snake_case
      case DebtType.carLoan:
        return 'car_loan';  // ✅ snake_case
      case DebtType.homeLoan:
        return 'home_loan';  // ✅ snake_case
      case DebtType.studentLoan:
        return 'student_loan';  // ✅ snake_case
      case DebtType.businessLoan:
        return 'business_loan';  // ✅ snake_case
      case DebtType.other:
        return 'other';
    }
  }

  // Helper: Convert database string to DebtType
  static DebtType _stringToDebtType(String type) {
    switch (type) {
      case 'credit_card':
        return DebtType.creditCard;
      case 'personal_loan':
        return DebtType.personalLoan;
      case 'car_loan':
        return DebtType.carLoan;
      case 'home_loan':
        return DebtType.homeLoan;
      case 'student_loan':
        return DebtType.studentLoan;
      case 'business_loan':
        return DebtType.businessLoan;
      case 'other':
        return DebtType.other;
      default:
        return DebtType.other;
    }
  }

  @override
  String toString() {
    return 'FinancialDebt(id: $id, debtName: $debtName, type: $debtType, balance: $currentBalance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FinancialDebt && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Debt type utilities
class DebtTypeUtils {
  static String getDebtTypeLabel(DebtType type) {
    switch (type) {
      case DebtType.creditCard:
        return 'Credit Card';
      case DebtType.personalLoan:
        return 'Personal Loan';
      case DebtType.carLoan:
        return 'Car Loan';
      case DebtType.homeLoan:
        return 'Home Loan';
      case DebtType.studentLoan:
        return 'Student Loan';
      case DebtType.businessLoan:
        return 'Business Loan';
      case DebtType.other:
        return 'Other';
    }
  }

  static String getDebtTypeEmoji(DebtType type) {
    switch (type) {
      case DebtType.creditCard:
        return '💳';
      case DebtType.personalLoan:
        return '💰';
      case DebtType.carLoan:
        return '🚗';
      case DebtType.homeLoan:
        return '🏠';
      case DebtType.studentLoan:
        return '📚';
      case DebtType.businessLoan:
        return '🏢';
      case DebtType.other:
        return '📋';
    }
  }

  // Calculate total debt
  static double calculateTotalDebt(List<FinancialDebt> debts) {
    return debts
        .where((debt) => debt.isActive)
        .fold(0.0, (sum, debt) => sum + debt.currentBalance);
  }

  // Calculate total monthly payments
  static double calculateTotalMonthlyPayment(List<FinancialDebt> debts) {
    return debts
        .where((debt) => debt.isActive)
        .fold(0.0, (sum, debt) => sum + debt.minimumPayment);
  }

  // Get debts by priority (sorted by interest rate)
  static List<FinancialDebt> getDebtsByPriority(List<FinancialDebt> debts) {
    final activeDebts = debts.where((debt) => debt.isActive).toList();
    activeDebts.sort((a, b) => b.interestRate.compareTo(a.interestRate));
    return activeDebts;
  }

  // Calculate debt-to-income ratio
  static double calculateDebtToIncomeRatio(
      List<FinancialDebt> debts,
      double monthlyIncome,
      ) {
    if (monthlyIncome <= 0) return 0.0;
    final totalMonthlyPayment = calculateTotalMonthlyPayment(debts);
    return (totalMonthlyPayment / monthlyIncome) * 100;
  }
}