// ✅ financial_account.dart - 基于 Supabase financial_accounts 表

enum AccountType {
  savings,
  checking,
  fixedDeposit,      // fixed_deposit in DB
  investment,
  retirement,
  business,
  eWallet,           // e_wallet in DB
  creditCard,        // credit_card in DB
}

class FinancialAccount {
  final String id;
  final String userId;
  final String accountName;
  final String? accountNumber;
  final AccountType accountType;
  final String bankName;
  final double currentBalance;
  final String currency;
  final bool isActive;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FinancialAccount({
    required this.id,
    required this.userId,
    required this.accountName,
    this.accountNumber,
    required this.accountType,
    required this.bankName,
    this.currentBalance = 0.0,
    this.currency = 'MYR',
    this.isActive = true,
    this.metadata,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Copy with method
  FinancialAccount copyWith({
    String? id,
    String? userId,
    String? accountName,
    String? accountNumber,
    AccountType? accountType,
    String? bankName,
    double? currentBalance,
    String? currency,
    bool? isActive,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinancialAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountType: accountType ?? this.accountType,
      bankName: bankName ?? this.bankName,
      currentBalance: currentBalance ?? this.currentBalance,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? (this.metadata != null ? Map.from(this.metadata!) : null),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Update balance
  FinancialAccount updateBalance(double newBalance) {
    return copyWith(
      currentBalance: newBalance,
      updatedAt: DateTime.now(),
    );
  }

  // Add to balance
  FinancialAccount addToBalance(double amount) {
    return copyWith(
      currentBalance: currentBalance + amount,
      updatedAt: DateTime.now(),
    );
  }

  // Subtract from balance
  FinancialAccount subtractFromBalance(double amount) {
    return copyWith(
      currentBalance: currentBalance - amount,
      updatedAt: DateTime.now(),
    );
  }

  // ✅ toJson 使用 snake_case
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,  // ✅ snake_case
      'account_name': accountName,  // ✅ snake_case
      'account_number': accountNumber,  // ✅ snake_case
      'account_type': _accountTypeToString(accountType),  // ✅ snake_case
      'bank_name': bankName,  // ✅ snake_case
      'current_balance': currentBalance,  // ✅ snake_case
      'currency': currency,
      'is_active': isActive,  // ✅ snake_case
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),  // ✅ snake_case
      'updated_at': updatedAt?.toIso8601String(),  // ✅ snake_case
    };
  }

  // ✅ fromJson 读取 snake_case
  factory FinancialAccount.fromJson(Map<String, dynamic> json) {
    return FinancialAccount(
      id: json['id'] as String,
      userId: json['user_id'] as String,  // ✅ snake_case
      accountName: json['account_name'] as String,  // ✅ snake_case
      accountNumber: json['account_number'] as String?,  // ✅ snake_case
      accountType: _stringToAccountType(json['account_type'] as String),  // ✅ snake_case
      bankName: json['bank_name'] as String,  // ✅ snake_case
      currentBalance: (json['current_balance'] as num?)?.toDouble() ?? 0.0,  // ✅ snake_case
      currency: json['currency'] as String? ?? 'MYR',
      isActive: json['is_active'] as bool? ?? true,  // ✅ snake_case
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),  // ✅ snake_case
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,  // ✅ snake_case
    );
  }

  // Helper: Convert AccountType to database string
  static String _accountTypeToString(AccountType type) {
    switch (type) {
      case AccountType.savings:
        return 'savings';
      case AccountType.checking:
        return 'checking';
      case AccountType.fixedDeposit:
        return 'fixed_deposit';  // ✅ snake_case
      case AccountType.investment:
        return 'investment';
      case AccountType.retirement:
        return 'retirement';
      case AccountType.business:
        return 'business';
      case AccountType.eWallet:
        return 'e_wallet';  // ✅ snake_case
      case AccountType.creditCard:
        return 'credit_card';  // ✅ snake_case
    }
  }

  // Helper: Convert database string to AccountType
  static AccountType _stringToAccountType(String type) {
    switch (type) {
      case 'savings':
        return AccountType.savings;
      case 'checking':
        return AccountType.checking;
      case 'fixed_deposit':
        return AccountType.fixedDeposit;
      case 'investment':
        return AccountType.investment;
      case 'retirement':
        return AccountType.retirement;
      case 'business':
        return AccountType.business;
      case 'e_wallet':
        return AccountType.eWallet;
      case 'credit_card':
        return AccountType.creditCard;
      default:
        return AccountType.savings;
    }
  }

  @override
  String toString() {
    return 'FinancialAccount(id: $id, accountName: $accountName, type: $accountType, balance: $currentBalance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FinancialAccount && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Account type utilities
class AccountTypeUtils {
  static String getAccountTypeLabel(AccountType type) {
    switch (type) {
      case AccountType.savings:
        return 'Savings Account';
      case AccountType.checking:
        return 'Checking Account';
      case AccountType.fixedDeposit:
        return 'Fixed Deposit';
      case AccountType.investment:
        return 'Investment Account';
      case AccountType.retirement:
        return 'Retirement Account';
      case AccountType.business:
        return 'Business Account';
      case AccountType.eWallet:
        return 'E-Wallet';
      case AccountType.creditCard:
        return 'Credit Card';
    }
  }

  static String getAccountTypeEmoji(AccountType type) {
    switch (type) {
      case AccountType.savings:
        return '🏦';
      case AccountType.checking:
        return '💳';
      case AccountType.fixedDeposit:
        return '🔒';
      case AccountType.investment:
        return '📈';
      case AccountType.retirement:
        return '🏝️';
      case AccountType.business:
        return '🏢';
      case AccountType.eWallet:
        return '📱';
      case AccountType.creditCard:
        return '💳';
    }
  }
}