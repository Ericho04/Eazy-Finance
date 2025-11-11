import 'package:flutter/material.dart';

class SFMSTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color dangerColor = Color(0xFFFF5722);

  // Cartoon Colors
  static const Color cartoonPink = Color(0xFFFF6B9D);
  static const Color cartoonPurple = Color(0xFF845EC2);
  static const Color cartoonBlue = Color(0xFF4E8EF7);
  static const Color cartoonCyan = Color(0xFF00D2FF);
  static const Color cartoonMint = Color(0xFF4FFBDF);
  static const Color cartoonYellow = Color(0xFFFFD93D);
  static const Color cartoonOrange = Color(0xFFFF8C42);

  // Neutral Colors
  static const Color neutralLight = Color(0xFFFAFAFA);
  static const Color neutralMedium = Color(0xFFE0E0E0);
  static const Color neutralDark = Color(0xFF9E9E9E);

  // AI Colors
  static const Color aiColor = Color(0xFF667eea);
  static const Color aiLight = Color(0xFFf0f2ff);

  // Background Colors
  static const Color backgroundColor = Color(0xFFf8faff);
  static const Color cardColor = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: successColor,
        surface: cardColor,
        background: backgroundColor,
        error: dangerColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    const darkBackgroundColor = Color(0xFF0f1419);
    const darkCardColor = Color(0xFF1c2128);
    const darkTextPrimary = Color(0xFFe6edf3);
    const darkTextSecondary = Color(0xFF8b949e);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: successColor,
        secondary: successColor,
        surface: darkCardColor,
        background: darkBackgroundColor,
        error: const Color(0xFFF44336),
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onBackground: darkTextPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: successColor,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkTextPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: darkTextSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkTextPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkTextPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: darkTextSecondary,
        ),
      ),
    );
  }

  // Helper methods for gradients
  static LinearGradient get successGradient {
    return LinearGradient(
      colors: [successColor, successColor.withOpacity(0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get warningGradient {
    return LinearGradient(
      colors: [warningColor, const Color(0xFFFFB74D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get dangerGradient {
    return LinearGradient(
      colors: [dangerColor, const Color(0xFFFF8A65)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get aiGradient {
    return const LinearGradient(
      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Cartoon gradients
  static LinearGradient get cartoonPinkGradient {
    return LinearGradient(
      colors: [cartoonPink, const Color(0xFFFF8CC8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get cartoonPurpleGradient {
    return LinearGradient(
      colors: [cartoonPurple, const Color(0xFFB39BC8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get cartoonBlueGradient {
    return LinearGradient(
      colors: [cartoonBlue, const Color(0xFF7BB3FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get cartoonCyanGradient {
    return LinearGradient(
      colors: [cartoonCyan, const Color(0xFF66E7FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get cartoonMintGradient {
    return LinearGradient(
      colors: [cartoonMint, const Color(0xFFA0FFE6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get cartoonYellowGradient {
    return LinearGradient(
      colors: [cartoonYellow, const Color(0xFFFFE066)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get cartoonOrangeGradient {
    return LinearGradient(
      colors: [cartoonOrange, const Color(0xFFFFAB66)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // ==========================================================================
  // ✅ 修复：支出分类（expense_entry_screen.dart:139 需要）
  // ==========================================================================

  static final List<Map<String, dynamic>> expenseCategories = [
    {
      'id': 'food',
      'name': 'Food & Dining',
      'emoji': '🍔',
      'color': cartoonOrange,
    },
    {
      'id': 'transport',
      'name': 'Transportation',
      'emoji': '🚗',
      'color': cartoonBlue,
    },
    {
      'id': 'shopping',
      'name': 'Shopping',
      'emoji': '🛍️',
      'color': cartoonPink,
    },
    {
      'id': 'entertainment',
      'name': 'Entertainment',
      'emoji': '🎬',
      'color': cartoonPurple,
    },
    {
      'id': 'bills',
      'name': 'Bills & Utilities',
      'emoji': '💡',
      'color': warningColor,
    },
    {
      'id': 'healthcare',
      'name': 'Healthcare',
      'emoji': '⚕️',
      'color': dangerColor,
    },
    {
      'id': 'education',
      'name': 'Education',
      'emoji': '📚',
      'color': cartoonCyan,
    },
    {
      'id': 'groceries',
      'name': 'Groceries',
      'emoji': '🛒',
      'color': cartoonMint,
    },
    {
      'id': 'personal',
      'name': 'Personal Care',
      'emoji': '💅',
      'color': cartoonPink,
    },
    {
      'id': 'other',
      'name': 'Other',
      'emoji': '📦',
      'color': neutralDark,
    },
  ];

  // ==========================================================================
  // ✅ 修复：收入分类（expense_entry_screen.dart:140 需要）
  // ==========================================================================

  static final List<Map<String, dynamic>> incomeCategories = [
    {
      'id': 'salary',
      'name': 'Salary',
      'emoji': '💼',
      'color': successColor,
    },
    {
      'id': 'business',
      'name': 'Business',
      'emoji': '🏢',
      'color': cartoonBlue,
    },
    {
      'id': 'investment',
      'name': 'Investment',
      'emoji': '📈',
      'color': cartoonCyan,
    },
    {
      'id': 'freelance',
      'name': 'Freelance',
      'emoji': '💻',
      'color': cartoonPurple,
    },
    {
      'id': 'rental',
      'name': 'Rental Income',
      'emoji': '🏠',
      'color': cartoonMint,
    },
    {
      'id': 'gift',
      'name': 'Gift',
      'emoji': '🎁',
      'color': cartoonPink,
    },
    {
      'id': 'bonus',
      'name': 'Bonus',
      'emoji': '💰',
      'color': cartoonYellow,
    },
    {
      'id': 'refund',
      'name': 'Refund',
      'emoji': '↩️',
      'color': cartoonOrange,
    },
    {
      'id': 'other',
      'name': 'Other',
      'emoji': '💵',
      'color': neutralDark,
    },
  ];
}