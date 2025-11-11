import 'package:flutter/material.dart';

class SFMSTheme {
  // ==========================================================================
  // 🎨 COLOR PALETTE VARIATIONS
  // Modern Flat-Vector Cartoon Style for Financial Apps
  // Inspired by: Wealthsimple, Plum, Revolut
  // ==========================================================================

  // ------ Palette 1: Deep Blue Trust (DEFAULT) ------
  // Professional, trustworthy, calm - ideal for financial security
  static const Color palette1Primary = Color(0xFF1E3A8A);      // Deep Blue
  static const Color palette1PrimaryLight = Color(0xFF3B82F6); // Light Blue
  static const Color palette1Accent = Color(0xFF10B981);       // Success Green
  static const Color palette1AccentAlt = Color(0xFFFACC15);    // Gold Highlight
  static const Color palette1Surface = Color(0xFFF8FAFC);      // Soft White
  static const Color palette1SurfaceVariant = Color(0xFFEFF6FF); // Light Blue Tint

  // ------ Palette 2: Teal Prosperity ------
  // Fresh, modern, growth-oriented - emphasizes financial growth
  static const Color palette2Primary = Color(0xFF0D9488);      // Teal
  static const Color palette2PrimaryLight = Color(0xFF14B8A6); // Light Teal
  static const Color palette2Accent = Color(0xFFFACC15);       // Gold
  static const Color palette2AccentAlt = Color(0xFF10B981);    // Green
  static const Color palette2Surface = Color(0xFFF0FDFA);      // Mint Tint
  static const Color palette2SurfaceVariant = Color(0xFFCCFBF1); // Light Teal Tint

  // ------ Palette 3: Royal Indigo Confidence ------
  // Sophisticated, premium, confident - for high-value financial apps
  static const Color palette3Primary = Color(0xFF4338CA);      // Royal Indigo
  static const Color palette3PrimaryLight = Color(0xFF6366F1); // Light Indigo
  static const Color palette3Accent = Color(0xFF10B981);       // Success Green
  static const Color palette3AccentAlt = Color(0xFFF59E0B);    // Amber/Gold
  static const Color palette3Surface = Color(0xFFFAF5FF);      // Soft Purple Tint
  static const Color palette3SurfaceVariant = Color(0xFFEDE9FE); // Light Indigo Tint

  // ==========================================================================
  // 🎯 ACTIVE THEME COLORS (Palette 1 by default)
  // To switch palettes, change these assignments to palette2/palette3
  // ==========================================================================

  static const Color primaryColor = palette1Primary;
  static const Color primaryLight = palette1PrimaryLight;
  static const Color accentColor = palette1Accent;
  static const Color accentAlt = palette1AccentAlt;

  // Status Colors - Universal across all palettes
  static const Color successColor = Color(0xFF10B981);  // Green
  static const Color warningColor = Color(0xFFF59E0B);  // Amber
  static const Color dangerColor = Color(0xFFEF4444);   // Red
  static const Color infoColor = Color(0xFF3B82F6);     // Blue

  // Flat-Vector Cartoon Accent Colors
  // Softer, more professional versions for financial UI
  static const Color cartoonMint = Color(0xFF6EE7B7);    // Soft Mint
  static const Color cartoonBlue = Color(0xFF60A5FA);    // Sky Blue
  static const Color cartoonPurple = Color(0xFFA78BFA);  // Lavender
  static const Color cartoonPink = Color(0xFFF472B6);    // Rose Pink
  static const Color cartoonYellow = Color(0xFFFBBF24);  // Sunny Yellow
  static const Color cartoonOrange = Color(0xFFFB923C);  // Peach Orange
  static const Color cartoonCyan = Color(0xFF22D3EE);    // Cyan
  static const Color cartoonTeal = Color(0xFF2DD4BF);    // Teal

  // Neutral Colors - Refined for professional look
  static const Color neutralLight = Color(0xFFF9FAFB);   // Off-White
  static const Color neutralMedium = Color(0xFFE5E7EB);  // Light Grey
  static const Color neutralDark = Color(0xFF6B7280);    // Medium Grey
  static const Color neutralDarker = Color(0xFF374151); // Dark Grey

  // AI & Premium Features Colors
  static const Color aiPrimary = Color(0xFF8B5CF6);      // Purple
  static const Color aiSecondary = Color(0xFFEC4899);    // Pink
  static const Color aiLight = Color(0xFFFAF5FF);        // Light Purple
  static const Color premiumGold = Color(0xFFFBBF24);    // Gold

  // Background Colors with Soft Gradients
  static const Color backgroundColor = palette1Surface;
  static const Color backgroundVariant = palette1SurfaceVariant;
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color cardColorTinted = Color(0xFFFDFDFD);

  // Text Colors - Optimized for readability
  static const Color textPrimary = Color(0xFF111827);    // Almost Black
  static const Color textSecondary = Color(0xFF6B7280);  // Medium Grey
  static const Color textMuted = Color(0xFF9CA3AF);      // Light Grey
  static const Color textOnPrimary = Color(0xFFFFFFFF);  // White
  static const Color textOnAccent = Color(0xFFFFFFFF);   // White

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: accentColor,
        tertiary: accentAlt,
        surface: cardColor,
        background: backgroundColor,
        error: dangerColor,
        onPrimary: textOnPrimary,
        onSecondary: textOnAccent,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textPrimary, size: 24),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.04),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textOnPrimary,
          elevation: 0,
          shadowColor: primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: neutralLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: neutralMedium, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: dangerColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: dangerColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(
          color: textMuted,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: textOnAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: neutralDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: neutralLight,
        selectedColor: primaryColor.withOpacity(0.15),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: neutralMedium,
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        // Display - Large headlines & hero numbers
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -1.5,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -1,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        // Headlines - Section titles
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.25,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.4,
        ),
        // Titles - Card headers & labels
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.15,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        // Body - Main content text
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: 0.1,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          letterSpacing: 0.25,
          height: 1.5,
        ),
        // Labels - Buttons, chips, tags
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
          height: 1.2,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: 0.4,
          height: 1.2,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 0.5,
          height: 1.2,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    const darkBackgroundColor = Color(0xFF0A0E27);
    const darkBackgroundVariant = Color(0xFF141938);
    const darkCardColor = Color(0xFF1A1F3A);
    const darkTextPrimary = Color(0xFFE8EAF6);
    const darkTextSecondary = Color(0xFF9FA8DA);
    const darkNeutralMedium = Color(0xFF3A4059);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryLight,
        brightness: Brightness.dark,
        primary: primaryLight,
        secondary: accentColor,
        tertiary: accentAlt,
        surface: darkCardColor,
        background: darkBackgroundColor,
        error: dangerColor,
        onPrimary: Colors.white,
        onSecondary: textOnAccent,
        onSurface: darkTextPrimary,
        onBackground: darkTextPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: darkTextPrimary, size: 24),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCardColor,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.3),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: primaryLight.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          side: const BorderSide(color: primaryLight, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBackgroundVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: darkNeutralMedium, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: dangerColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: dangerColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(
          color: darkTextSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: textOnAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkCardColor,
        selectedItemColor: primaryLight,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkBackgroundVariant,
        selectedColor: primaryLight.withOpacity(0.2),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: darkNeutralMedium,
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        // Display - Large headlines & hero numbers
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: darkTextPrimary,
          letterSpacing: -1.5,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
          letterSpacing: -1,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        // Headlines - Section titles
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: -0.25,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          height: 1.4,
        ),
        // Titles - Card headers & labels
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: 0.15,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        // Body - Main content text
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkTextPrimary,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkTextPrimary,
          letterSpacing: 0.1,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: darkTextSecondary,
          letterSpacing: 0.25,
          height: 1.5,
        ),
        // Labels - Buttons, chips, tags
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: 0.5,
          height: 1.2,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkTextPrimary,
          letterSpacing: 0.4,
          height: 1.2,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: darkTextSecondary,
          letterSpacing: 0.5,
          height: 1.2,
        ),
      ),
    );
  }

  // ==========================================================================
  // 🎨 MODERN FLAT-VECTOR GRADIENTS
  // Subtle, professional gradients for financial UI elements
  // ==========================================================================

  // Primary Brand Gradients
  static LinearGradient get primaryGradient {
    return const LinearGradient(
      colors: [primaryColor, primaryLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get accentGradient {
    return const LinearGradient(
      colors: [accentColor, Color(0xFF34D399)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get goldGradient {
    return const LinearGradient(
      colors: [accentAlt, Color(0xFFFDE047)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Status Gradients
  static LinearGradient get successGradient {
    return const LinearGradient(
      colors: [successColor, Color(0xFF34D399)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get warningGradient {
    return const LinearGradient(
      colors: [warningColor, Color(0xFFFBBF24)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get dangerGradient {
    return const LinearGradient(
      colors: [dangerColor, Color(0xFFF87171)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get infoGradient {
    return const LinearGradient(
      colors: [infoColor, Color(0xFF60A5FA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // AI & Premium Gradients
  static LinearGradient get aiGradient {
    return const LinearGradient(
      colors: [aiPrimary, aiSecondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get premiumGradient {
    return const LinearGradient(
      colors: [Color(0xFFFBBF24), Color(0xFFFDE047), Color(0xFFFACC15)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Background Gradients - Soft tints for cards and sections
  static LinearGradient get backgroundGradientBlue {
    return const LinearGradient(
      colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static LinearGradient get backgroundGradientTeal {
    return const LinearGradient(
      colors: [Color(0xFFF0FDFA), Color(0xFFCCFBF1)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static LinearGradient get backgroundGradientPurple {
    return const LinearGradient(
      colors: [Color(0xFFFAF5FF), Color(0xFFEDE9FE)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  // Flat-Vector Cartoon Category Gradients
  static LinearGradient get cartoonMintGradient {
    return const LinearGradient(
      colors: [cartoonMint, Color(0xFF86EFAC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get cartoonBlueGradient {
    return const LinearGradient(
      colors: [cartoonBlue, Color(0xFF93C5FD)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get cartoonPurpleGradient {
    return const LinearGradient(
      colors: [cartoonPurple, Color(0xFFC4B5FD)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get cartoonPinkGradient {
    return const LinearGradient(
      colors: [cartoonPink, Color(0xFFF9A8D4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get cartoonYellowGradient {
    return const LinearGradient(
      colors: [cartoonYellow, Color(0xFFFDE047)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get cartoonOrangeGradient {
    return const LinearGradient(
      colors: [cartoonOrange, Color(0xFFFDBA74)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get cartoonCyanGradient {
    return const LinearGradient(
      colors: [cartoonCyan, Color(0xFF67E8F9)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get cartoonTealGradient {
    return const LinearGradient(
      colors: [cartoonTeal, Color(0xFF5EEAD4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // ==========================================================================
  // 💳 EXPENSE & INCOME CATEGORIES
  // Updated with professional flat-vector color scheme
  // ==========================================================================

  static final List<Map<String, dynamic>> expenseCategories = [
    {
      'id': 'food',
      'name': 'Food & Dining',
      'emoji': '🍔',
      'color': cartoonOrange,
      'gradient': cartoonOrangeGradient,
    },
    {
      'id': 'transport',
      'name': 'Transportation',
      'emoji': '🚗',
      'color': cartoonBlue,
      'gradient': cartoonBlueGradient,
    },
    {
      'id': 'shopping',
      'name': 'Shopping',
      'emoji': '🛍️',
      'color': cartoonPink,
      'gradient': cartoonPinkGradient,
    },
    {
      'id': 'entertainment',
      'name': 'Entertainment',
      'emoji': '🎬',
      'color': cartoonPurple,
      'gradient': cartoonPurpleGradient,
    },
    {
      'id': 'bills',
      'name': 'Bills & Utilities',
      'emoji': '💡',
      'color': warningColor,
      'gradient': warningGradient,
    },
    {
      'id': 'healthcare',
      'name': 'Healthcare',
      'emoji': '⚕️',
      'color': dangerColor,
      'gradient': dangerGradient,
    },
    {
      'id': 'education',
      'name': 'Education',
      'emoji': '📚',
      'color': cartoonCyan,
      'gradient': cartoonCyanGradient,
    },
    {
      'id': 'groceries',
      'name': 'Groceries',
      'emoji': '🛒',
      'color': cartoonMint,
      'gradient': cartoonMintGradient,
    },
    {
      'id': 'personal',
      'name': 'Personal Care',
      'emoji': '💅',
      'color': cartoonPink,
      'gradient': cartoonPinkGradient,
    },
    {
      'id': 'other',
      'name': 'Other',
      'emoji': '📦',
      'color': neutralDark,
      'gradient': null,
    },
  ];

  static final List<Map<String, dynamic>> incomeCategories = [
    {
      'id': 'salary',
      'name': 'Salary',
      'emoji': '💼',
      'color': successColor,
      'gradient': successGradient,
    },
    {
      'id': 'business',
      'name': 'Business',
      'emoji': '🏢',
      'color': primaryColor,
      'gradient': primaryGradient,
    },
    {
      'id': 'investment',
      'name': 'Investment',
      'emoji': '📈',
      'color': cartoonCyan,
      'gradient': cartoonCyanGradient,
    },
    {
      'id': 'freelance',
      'name': 'Freelance',
      'emoji': '💻',
      'color': cartoonPurple,
      'gradient': cartoonPurpleGradient,
    },
    {
      'id': 'rental',
      'name': 'Rental Income',
      'emoji': '🏠',
      'color': cartoonTeal,
      'gradient': cartoonTealGradient,
    },
    {
      'id': 'gift',
      'name': 'Gift',
      'emoji': '🎁',
      'color': cartoonPink,
      'gradient': cartoonPinkGradient,
    },
    {
      'id': 'bonus',
      'name': 'Bonus',
      'emoji': '💰',
      'color': accentAlt,
      'gradient': goldGradient,
    },
    {
      'id': 'refund',
      'name': 'Refund',
      'emoji': '↩️',
      'color': infoColor,
      'gradient': infoGradient,
    },
    {
      'id': 'other',
      'name': 'Other',
      'emoji': '💵',
      'color': successColor,
      'gradient': successGradient,
    },
  ];

  // ==========================================================================
  // 🛠️ UTILITY METHODS
  // Helper methods for creating modern flat-vector UI elements
  // ==========================================================================

  /// Creates a soft shadow for elevated cards (flat design)
  static List<BoxShadow> get softCardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// Creates a prominent shadow for floating elements
  static List<BoxShadow> get floatingShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  /// Creates a colored shadow for accent buttons
  static List<BoxShadow> accentShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  /// Returns a status color based on budget health or goal progress
  static Color getStatusColor(double percentage) {
    if (percentage >= 90) return dangerColor;
    if (percentage >= 70) return warningColor;
    if (percentage >= 50) return infoColor;
    return successColor;
  }

  /// Returns a gradient based on budget health or goal progress
  static LinearGradient getStatusGradient(double percentage) {
    if (percentage >= 90) return dangerGradient;
    if (percentage >= 70) return warningGradient;
    if (percentage >= 50) return infoGradient;
    return successGradient;
  }

  /// Creates a shimmer effect color for loading states
  static Color get shimmerBaseColor => neutralLight;
  static Color get shimmerHighlightColor => Colors.white;

  /// Icon sizes following consistent visual hierarchy
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeXLarge = 32.0;
  static const double iconSizeHero = 48.0;

  /// Border radius values for consistent rounded corners
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 24.0;
  static const double radiusFull = 9999.0;

  /// Spacing values for consistent layout
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
}