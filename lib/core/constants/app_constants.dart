class AppConstants {
  // App Info
  static const String appName = 'Easy Finance';
  static const String appTagline = 'Smart Personal Finance for Malaysia';

  // Currency
  static const String currency = 'MYR';
  static const String currencySymbol = 'RM';
  static const String locale = 'ms_MY';

  // Database
  static const String localDbName = 'easy_finance.db';
  static const int localDbVersion = 1;

  // Supabase (to be configured via environment)
  static const String supabaseUrlKey = 'SUPABASE_URL';
  static const String supabaseAnonKeyKey = 'SUPABASE_ANON_KEY';

  // Thresholds
  static const double budgetWarningThreshold = 0.8; // 80%
  static const double budgetExceededThreshold = 1.0; // 100%

  // DTI Thresholds
  static const double dtiSafeThreshold = 0.36; // 36%
  static const double dtiBorderlineThreshold = 0.43; // 43%

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String shortDateFormat = 'dd/MM/yyyy';
  static const String monthYearFormat = 'MMM yyyy';

  // Limits
  static const int maxNotesLength = 500;
  static const int maxTitleLength = 100;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
