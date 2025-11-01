// Financial model for managing various financial instruments and data

// Financial Account model
class FinancialAccount {
  final String id;
  final String userId;
  final String accountName;
  final String accountNumber;
  final FinancialAccountType type;
  final String bankName;
  final double currentBalance;
  final String currency;
  final DateTime lastUpdated;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  FinancialAccount({
    required this.id,
    required this.userId,
    required this.accountName,
    required this.accountNumber,
    required this.type,
    required this.bankName,
    required this.currentBalance,
    this.currency = 'MYR',
    DateTime? lastUpdated,
    this.isActive = true,
    this.metadata,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  FinancialAccount copyWith({
    String? id,
    String? userId,
    String? accountName,
    String? accountNumber,
    FinancialAccountType? type,
    String? bankName,
    double? currentBalance,
    String? currency,
    DateTime? lastUpdated,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return FinancialAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      type: type ?? this.type,
      bankName: bankName ?? this.bankName,
      currentBalance: currentBalance ?? this.currentBalance,
      currency: currency ?? this.currency,
      lastUpdated: lastUpdated ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'accountName': accountName,
      'accountNumber': accountNumber,
      'type': type.toString().split('.').last,
      'bankName': bankName,
      'currentBalance': currentBalance,
      'currency': currency,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  factory FinancialAccount.fromJson(Map<String, dynamic> json) {
    return FinancialAccount(
      id: json['id'] as String,
      userId: json['userId'] as String,
      accountName: json['accountName'] as String,
      accountNumber: json['accountNumber'] as String,
      type: FinancialAccountType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      bankName: json['bankName'] as String,
      currentBalance: (json['currentBalance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'MYR',
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isActive: json['isActive'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'FinancialAccount(id: $id, accountName: $accountName, type: $type, currentBalance: $currentBalance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FinancialAccount && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Financial Debt model
class FinancialDebt {
  final String id;
  final String userId;
  final String debtName;
  final DebtType type;
  final double originalAmount;
  final double currentBalance;
  final double interestRate;
  final double minimumPayment;
  final String dueDate;
  final String creditorName;
  final DateTime createdAt;
  final DateTime? lastPaymentDate;
  final bool isActive;

  FinancialDebt({
    required this.id,
    required this.userId,
    required this.debtName,
    required this.type,
    required this.originalAmount,
    required this.currentBalance,
    required this.interestRate,
    required this.minimumPayment,
    required this.dueDate,
    required this.creditorName,
    DateTime? createdAt,
    this.lastPaymentDate,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  // Calculate debt progress percentage
  double get progressPercentage {
    if (originalAmount <= 0) return 0.0;
    final paidAmount = originalAmount - currentBalance;
    return (paidAmount / originalAmount) * 100;
  }

  // Calculate remaining debt percentage
  double get remainingPercentage {
    return 100 - progressPercentage;
  }

  // Check if payment is overdue
  bool get isOverdue {
    if (!isActive || dueDate.isEmpty) return false;
    final due = DateTime.parse(dueDate);
    return DateTime.now().isAfter(due);
  }

  // Days until next payment
  int get daysUntilDue {
    if (dueDate.isEmpty) return -1;
    final due = DateTime.parse(dueDate);
    final difference = due.difference(DateTime.now()).inDays;
    return difference < 0 ? 0 : difference;
  }

  FinancialDebt copyWith({
    String? id,
    String? userId,
    String? debtName,
    DebtType? type,
    double? originalAmount,
    double? currentBalance,
    double? interestRate,
    double? minimumPayment,
    String? dueDate,
    String? creditorName,
    DateTime? createdAt,
    DateTime? lastPaymentDate,
    bool? isActive,
  }) {
    return FinancialDebt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      debtName: debtName ?? this.debtName,
      type: type ?? this.type,
      originalAmount: originalAmount ?? this.originalAmount,
      currentBalance: currentBalance ?? this.currentBalance,
      interestRate: interestRate ?? this.interestRate,
      minimumPayment: minimumPayment ?? this.minimumPayment,
      dueDate: dueDate ?? this.dueDate,
      creditorName: creditorName ?? this.creditorName,
      createdAt: createdAt ?? this.createdAt,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'debtName': debtName,
      'type': type.toString().split('.').last,
      'originalAmount': originalAmount,
      'currentBalance': currentBalance,
      'interestRate': interestRate,
      'minimumPayment': minimumPayment,
      'dueDate': dueDate,
      'creditorName': creditorName,
      'createdAt': createdAt.toIso8601String(),
      'lastPaymentDate': lastPaymentDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory FinancialDebt.fromJson(Map<String, dynamic> json) {
    return FinancialDebt(
      id: json['id'] as String,
      userId: json['userId'] as String,
      debtName: json['debtName'] as String,
      type: DebtType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      originalAmount: (json['originalAmount'] as num).toDouble(),
      currentBalance: (json['currentBalance'] as num).toDouble(),
      interestRate: (json['interestRate'] as num).toDouble(),
      minimumPayment: (json['minimumPayment'] as num).toDouble(),
      dueDate: json['dueDate'] as String,
      creditorName: json['creditorName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastPaymentDate: json['lastPaymentDate'] != null
          ? DateTime.parse(json['lastPaymentDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  String toString() {
    return 'FinancialDebt(id: $id, debtName: $debtName, type: $type, currentBalance: $currentBalance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FinancialDebt && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Tax Planning model
class TaxPlanning {
  final String id;
  final String userId;
  final String taxYear;
  final double annualIncome;
  final double estimatedTax;
  final double totalDeductions;
  final double taxableIncome;
  final double effectiveRate;
  final List<TaxDeduction> deductions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TaxPlanning({
    required this.id,
    required this.userId,
    required this.taxYear,
    required this.annualIncome,
    required this.estimatedTax,
    required this.totalDeductions,
    required this.taxableIncome,
    required this.effectiveRate,
    required this.deductions,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Calculate tax savings from deductions
  double get taxSavings {
    // Approximate tax savings based on effective rate
    return totalDeductions * (effectiveRate / 100);
  }

  // Calculate take-home income after tax
  double get takeHomeIncome {
    return annualIncome - estimatedTax;
  }

  TaxPlanning copyWith({
    String? id,
    String? userId,
    String? taxYear,
    double? annualIncome,
    double? estimatedTax,
    double? totalDeductions,
    double? taxableIncome,
    double? effectiveRate,
    List<TaxDeduction>? deductions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaxPlanning(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taxYear: taxYear ?? this.taxYear,
      annualIncome: annualIncome ?? this.annualIncome,
      estimatedTax: estimatedTax ?? this.estimatedTax,
      totalDeductions: totalDeductions ?? this.totalDeductions,
      taxableIncome: taxableIncome ?? this.taxableIncome,
      effectiveRate: effectiveRate ?? this.effectiveRate,
      deductions: deductions ?? List.from(this.deductions),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'taxYear': taxYear,
      'annualIncome': annualIncome,
      'estimatedTax': estimatedTax,
      'totalDeductions': totalDeductions,
      'taxableIncome': taxableIncome,
      'effectiveRate': effectiveRate,
      'deductions': deductions.map((d) => d.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory TaxPlanning.fromJson(Map<String, dynamic> json) {
    return TaxPlanning(
      id: json['id'] as String,
      userId: json['userId'] as String,
      taxYear: json['taxYear'] as String,
      annualIncome: (json['annualIncome'] as num).toDouble(),
      estimatedTax: (json['estimatedTax'] as num).toDouble(),
      totalDeductions: (json['totalDeductions'] as num).toDouble(),
      taxableIncome: (json['taxableIncome'] as num).toDouble(),
      effectiveRate: (json['effectiveRate'] as num).toDouble(),
      deductions: (json['deductions'] as List)
          .map((d) => TaxDeduction.fromJson(d as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'TaxPlanning(id: $id, taxYear: $taxYear, annualIncome: $annualIncome, estimatedTax: $estimatedTax)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaxPlanning && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Tax Deduction model
class TaxDeduction {
  final String id;
  final String category;
  final String description;
  final double amount;
  final double maxAmount;
  final bool isClaimable;

  TaxDeduction({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.maxAmount,
    this.isClaimable = true,
  });

  // Calculate utilization percentage
  double get utilizationPercentage {
    if (maxAmount <= 0) return 0.0;
    return (amount / maxAmount) * 100;
  }

  // Check if maximum is reached
  bool get isMaxReached {
    return amount >= maxAmount;
  }

  // Calculate remaining claimable amount
  double get remainingAmount {
    final remaining = maxAmount - amount;
    return remaining < 0 ? 0 : remaining;
  }

  TaxDeduction copyWith({
    String? id,
    String? category,
    String? description,
    double? amount,
    double? maxAmount,
    bool? isClaimable,
  }) {
    return TaxDeduction(
      id: id ?? this.id,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      maxAmount: maxAmount ?? this.maxAmount,
      isClaimable: isClaimable ?? this.isClaimable,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'amount': amount,
      'maxAmount': maxAmount,
      'isClaimable': isClaimable,
    };
  }

  factory TaxDeduction.fromJson(Map<String, dynamic> json) {
    return TaxDeduction(
      id: json['id'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      maxAmount: (json['maxAmount'] as num).toDouble(),
      isClaimable: json['isClaimable'] as bool? ?? true,
    );
  }

  @override
  String toString() {
    return 'TaxDeduction(id: $id, category: $category, amount: $amount, maxAmount: $maxAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaxDeduction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Enums for financial types
enum FinancialAccountType {
  savings,
  checking,
  fixedDeposit,
  investment,
  retirement,
  business,
  eWallet,
  creditCard,
}

enum DebtType {
  creditCard,
  personalLoan,
  carLoan,
  homeLoan,
  studentLoan,
  businessLoan,
  other,
}

// Financial constants and utilities
class FinancialConstants {
  // Account type mappings
  static const Map<FinancialAccountType, String> accountTypeLabels = {
    FinancialAccountType.savings: 'Savings Account',
    FinancialAccountType.checking: 'Checking Account',
    FinancialAccountType.fixedDeposit: 'Fixed Deposit',
    FinancialAccountType.investment: 'Investment Account',
    FinancialAccountType.retirement: 'Retirement Account',
    FinancialAccountType.business: 'Business Account',
    FinancialAccountType.eWallet: 'E-Wallet',
    FinancialAccountType.creditCard: 'Credit Card',
  };

  static const Map<FinancialAccountType, String> accountTypeEmojis = {
    FinancialAccountType.savings: '💰',
    FinancialAccountType.checking: '🏦',
    FinancialAccountType.fixedDeposit: '📈',
    FinancialAccountType.investment: '📊',
    FinancialAccountType.retirement: '🏛️',
    FinancialAccountType.business: '🏢',
    FinancialAccountType.eWallet: '📱',
    FinancialAccountType.creditCard: '💳',
  };

  // Debt type mappings
  static const Map<DebtType, String> debtTypeLabels = {
    DebtType.creditCard: 'Credit Card',
    DebtType.personalLoan: 'Personal Loan',
    DebtType.carLoan: 'Car Loan',
    DebtType.homeLoan: 'Home Loan',
    DebtType.studentLoan: 'Student Loan',
    DebtType.businessLoan: 'Business Loan',
    DebtType.other: 'Other Debt',
  };

  static const Map<DebtType, String> debtTypeEmojis = {
    DebtType.creditCard: '💳',
    DebtType.personalLoan: '🏦',
    DebtType.carLoan: '🚗',
    DebtType.homeLoan: '🏠',
    DebtType.studentLoan: '🎓',
    DebtType.businessLoan: '🏢',
    DebtType.other: '💰',
  };

  // Malaysia Tax Deduction Categories (2024)
  static const Map<String, double> malaysiaTaxDeductions = {
    'EPF Contribution': 4000.0,
    'Life Insurance': 3000.0,
    'Education Fees': 7000.0,
    'Medical Expenses': 8000.0,
    'Parent Medical': 8000.0,
    'Disabled Individual': 6000.0,
    'Books/Journals': 1000.0,
    'Computer Purchase': 2500.0,
    'Child Care Fees': 3000.0,
    'Sports Equipment': 300.0,
  };

  // Utility methods
  static String getAccountTypeLabel(FinancialAccountType type) {
    return accountTypeLabels[type] ?? 'Unknown Account';
  }

  static String getAccountTypeEmoji(FinancialAccountType type) {
    return accountTypeEmojis[type] ?? '🏦';
  }

  static String getDebtTypeLabel(DebtType type) {
    return debtTypeLabels[type] ?? 'Unknown Debt';
  }

  static String getDebtTypeEmoji(DebtType type) {
    return debtTypeEmojis[type] ?? '💰';
  }

  // Calculate Malaysia individual income tax (2024 rates)
  static double calculateMalaysianTax(double taxableIncome) {
    if (taxableIncome <= 5000) return 0.0;
    if (taxableIncome <= 20000) return (taxableIncome - 5000) * 0.01;
    if (taxableIncome <= 35000) return 150 + (taxableIncome - 20000) * 0.03;
    if (taxableIncome <= 50000) return 600 + (taxableIncome - 35000) * 0.08;
    if (taxableIncome <= 70000) return 1800 + (taxableIncome - 50000) * 0.13;
    if (taxableIncome <= 100000) return 4400 + (taxableIncome - 70000) * 0.21;
    if (taxableIncome <= 250000) return 10700 + (taxableIncome - 100000) * 0.24;
    if (taxableIncome <= 400000) return 46700 + (taxableIncome - 250000) * 0.245;
    if (taxableIncome <= 600000) return 83450 + (taxableIncome - 400000) * 0.25;
    if (taxableIncome <= 1000000) return 133450 + (taxableIncome - 600000) * 0.26;
    return 237450 + (taxableIncome - 1000000) * 0.28;
  }

  // Calculate effective tax rate
  static double calculateEffectiveRate(double annualIncome, double tax) {
    if (annualIncome <= 0) return 0.0;
    return (tax / annualIncome) * 100;
  }
}