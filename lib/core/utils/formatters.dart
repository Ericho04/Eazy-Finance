import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Formatters {
  // Private constructor to prevent instantiation
  Formatters._();

  /// Format currency amount in MYR
  static String currency(double amount, {bool showSymbol = true}) {
    final formatter = NumberFormat.currency(
      locale: AppConstants.locale,
      symbol: showSymbol ? AppConstants.currencySymbol : '',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Format date
  static String date(DateTime date, {String? format}) {
    final formatter = DateFormat(format ?? AppConstants.dateFormat);
    return formatter.format(date);
  }

  /// Format date as short format
  static String shortDate(DateTime date) {
    return date(date, format: AppConstants.shortDateFormat);
  }

  /// Format month and year
  static String monthYear(DateTime date) {
    return date(date, format: AppConstants.monthYearFormat);
  }

  /// Format percentage
  static String percentage(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Format large numbers with K, M, B suffix
  static String compactNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }

  /// Format duration in days
  static String daysRemaining(int days) {
    if (days < 0) return 'Overdue by ${-days} days';
    if (days == 0) return 'Due today';
    if (days == 1) return '1 day remaining';
    return '$days days remaining';
  }

  /// Format phone number (Malaysian format)
  static String phoneNumber(String phone) {
    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.length == 10) {
      // Format: 012-345-6789
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11) {
      // Format: 0123-456-789
      return '${digits.substring(0, 4)}-${digits.substring(4, 7)}-${digits.substring(7)}';
    }

    return phone; // Return as is if format is unexpected
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
