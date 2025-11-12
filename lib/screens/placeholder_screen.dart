import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/theme.dart';

class PlaceholderScreen extends StatelessWidget {
  final String screenName;
  final Function()? onBack;
  final Function(String)? onNavigate;

  const PlaceholderScreen({
    Key? key,
    required this.screenName,
    this.onBack,
    this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Theme-aware colors
    final bgColor = isDarkMode ? SFMSTheme.darkBgPrimary : SFMSTheme.backgroundColor;
    final textPrimary = isDarkMode ? SFMSTheme.darkTextPrimary : SFMSTheme.textPrimary;
    final textSecondary = isDarkMode ? SFMSTheme.darkTextSecondary : SFMSTheme.textSecondary;
    final textMuted = isDarkMode ? SFMSTheme.darkTextSecondary.withOpacity(0.7) : SFMSTheme.textMuted;
    final cardBg = isDarkMode ? SFMSTheme.darkBgSecondary : SFMSTheme.cardColor;

    return Scaffold(
      appBar: onBack != null
          ? AppBar(
              title: Text(screenName, style: TextStyle(color: textPrimary)),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: textPrimary),
                onPressed: onBack,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: Container(
        decoration: isDarkMode
            ? BoxDecoration(color: bgColor)
            : const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFDBEAFE),
                    Color(0xFFFAF5FF),
                    Color(0xFFFDF2F8),
                  ],
                ),
              ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: cardBg,
                  shape: BoxShape.circle,
                  boxShadow: isDarkMode ? SFMSTheme.darkCardGlow : SFMSTheme.softCardShadow,
                ),
                child: Icon(
                  Icons.construction,
                  size: 60,
                  color: isDarkMode ? SFMSTheme.accentTeal : const Color(0xFF845EC2),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                screenName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'This screen is under development 🚧',
                style: TextStyle(
                  fontSize: 16,
                  color: textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Coming soon in the next update!',
                style: TextStyle(
                  fontSize: 14,
                  color: textMuted,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              if (onBack != null)
                ElevatedButton(
                  onPressed: onBack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? SFMSTheme.accentTeal : const Color(0xFF4E8EF7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back),
                      SizedBox(width: 8),
                      Text(
                        'Go Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Specific placeholder screens
class BudgetScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const BudgetScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      screenName: 'Budget Management',
      onNavigate: onNavigate,
    );
  }
}

class FinancialScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const FinancialScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      screenName: 'Financial Overview',
      onNavigate: onNavigate,
    );
  }
}

class FinancialDebtsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const FinancialDebtsScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      screenName: 'Debt Management',
      onBack: onBack,
    );
  }
}

class FinancialTaxScreen extends StatelessWidget {
  final VoidCallback onBack;

  const FinancialTaxScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      screenName: 'Tax Planning',
      onBack: onBack,
    );
  }
}

class GoalsScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const GoalsScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      screenName: 'Goals & Rewards',
      onNavigate: onNavigate,
    );
  }
}

class LuckyDrawScreen extends StatelessWidget {
  final VoidCallback onBack;

  const LuckyDrawScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      screenName: 'Lucky Draw 🎰',
      onBack: onBack,
    );
  }
}

class RewardsShopScreen extends StatelessWidget {
  final VoidCallback onBack;

  const RewardsShopScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      screenName: 'Rewards Shop 🛒',
      onBack: onBack,
    );
  }
}

class InsightsScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const InsightsScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      screenName: 'Financial Insights',
      onNavigate: onNavigate,
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const SettingsScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      screenName: 'Settings',
      onNavigate: onNavigate,
    );
  }
}

class ExpenseEntryScreen extends StatelessWidget {
  final VoidCallback onBack;
  final Function(String) onNavigate;
  final Map<String, dynamic>? prefilledData;

  const ExpenseEntryScreen({
    Key? key,
    required this.onBack,
    required this.onNavigate,
    this.prefilledData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      screenName: 'Add Expense',
      onBack: onBack,
    );
  }
}

class ExpenseHistoryScreen extends StatelessWidget {
  final VoidCallback onBack;

  const ExpenseHistoryScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      screenName: 'Expense History',
      onBack: onBack,
    );
  }
}

class ReportsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const ReportsScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      screenName: 'Reports & Analytics',
      onBack: onBack,
    );
  }
}

class OCRScannerScreen extends StatelessWidget {
  final VoidCallback onBack;
  final Function(Map<String, dynamic>) onScanComplete;

  const OCRScannerScreen({
    Key? key,
    required this.onBack,
    required this.onScanComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      screenName: 'OCR Scanner 📄',
      onBack: onBack,
    );
  }
}

class QRScannerScreen extends StatelessWidget {
  final VoidCallback onBack;
  final Function(Map<String, dynamic>) onScanComplete;

  const QRScannerScreen({
    Key? key,
    required this.onBack,
    required this.onScanComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      screenName: 'QR Code Scanner 📱',
      onBack: onBack,
    );
  }
}