// ✅ user_profile.dart - 基于 Supabase user_profiles 表

class UserProfile {
  final String id;  // UUID - 引用 auth.users(id)
  final String? fullName;
  final String? email;
  final String? avatarUrl;
  final String language;
  final String currency;
  final String timezone;
  final int rewardPoints;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    this.fullName,
    this.email,
    this.avatarUrl,
    this.language = 'en',
    this.currency = 'MYR',
    this.timezone = 'Asia/Kuala_Lumpur',
    this.rewardPoints = 0,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Copy with method for immutable updates
  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? language,
    String? currency,
    String? timezone,
    int? rewardPoints,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Add reward points
  UserProfile addRewardPoints(int points) {
    return copyWith(
      rewardPoints: rewardPoints + points,
      updatedAt: DateTime.now(),
    );
  }

  // Subtract reward points
  UserProfile subtractRewardPoints(int points) {
    final newPoints = rewardPoints - points;
    return copyWith(
      rewardPoints: newPoints < 0 ? 0 : newPoints,
      updatedAt: DateTime.now(),
    );
  }

  // ✅ toJson 使用 snake_case
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,  // ✅ snake_case
      'email': email,
      'avatar_url': avatarUrl,  // ✅ snake_case
      'language': language,
      'currency': currency,
      'timezone': timezone,
      'reward_points': rewardPoints,  // ✅ snake_case
      'created_at': createdAt.toIso8601String(),  // ✅ snake_case
      'updated_at': updatedAt?.toIso8601String(),  // ✅ snake_case
    };
  }

  // ✅ fromJson 读取 snake_case
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,  // ✅ snake_case
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,  // ✅ snake_case
      language: json['language'] as String? ?? 'en',
      currency: json['currency'] as String? ?? 'MYR',
      timezone: json['timezone'] as String? ?? 'Asia/Kuala_Lumpur',
      rewardPoints: json['reward_points'] as int? ?? 0,  // ✅ snake_case
      createdAt: DateTime.parse(json['created_at'] as String),  // ✅ snake_case
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,  // ✅ snake_case
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, fullName: $fullName, email: $email, rewardPoints: $rewardPoints)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Supported currencies
class SupportedCurrency {
  static const String myr = 'MYR';
  static const String usd = 'USD';
  static const String sgd = 'SGD';
  static const String eur = 'EUR';
  static const String gbp = 'GBP';

  static List<String> get allCurrencies => [myr, usd, sgd, eur, gbp];

  static Map<String, String> get currencySymbols => {
    myr: 'RM',
    usd: '\$',
    sgd: 'S\$',
    eur: '€',
    gbp: '£',
  };

  static String getCurrencySymbol(String currency) {
    return currencySymbols[currency] ?? currency;
  }
}

// Supported languages
class SupportedLanguage {
  static const String english = 'en';
  static const String malay = 'ms';
  static const String chinese = 'zh';

  static List<String> get allLanguages => [english, malay, chinese];

  static Map<String, String> get languageNames => {
    english: 'English',
    malay: 'Bahasa Melayu',
    chinese: '中文',
  };

  static String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? 'English';
  }
}