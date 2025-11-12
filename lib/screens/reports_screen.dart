import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/theme.dart';

class ReportsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ReportsScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dark Mode Support
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Theme-aware colors
    final bgColor = isDarkMode ? SFMSTheme.darkBgPrimary : SFMSTheme.backgroundColor;
    final textPrimary = isDarkMode ? SFMSTheme.darkTextPrimary : SFMSTheme.textPrimary;
    final textSecondary = isDarkMode ? SFMSTheme.darkTextSecondary : SFMSTheme.textSecondary;
    final cardColor = isDarkMode ? SFMSTheme.darkCardBg : Colors.white;
    final iconButtonBg = isDarkMode ? SFMSTheme.darkCardBg : Colors.white.withOpacity(0.9);
    final iconColor = isDarkMode ? SFMSTheme.darkTextPrimary : Colors.grey.shade700;
    final accentColor = isDarkMode ? SFMSTheme.darkAccentTeal : Colors.indigo.shade600;
    final accentBg = isDarkMode ? SFMSTheme.darkCardBg : Colors.indigo.shade50;
    final accentBorder = isDarkMode ? SFMSTheme.darkAccentTeal.withOpacity(0.3) : Colors.indigo.shade200;
    final bgGradient = isDarkMode
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              SFMSTheme.darkBgPrimary,
              SFMSTheme.darkBgSecondary,
            ],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDBEAFE),
              Color(0xFFFAF5FF),
              Color(0xFFFDF2F8),
            ],
          );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: bgGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: iconButtonBg,
                        foregroundColor: iconColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Reports',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.8 + (_animationController.value * 0.2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '📈',
                              style: TextStyle(fontSize: 80),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Financial Reports',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Generate detailed reports of your spending patterns, budgets, and financial trends.',
                              style: TextStyle(
                                fontSize: 16,
                                color: textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: accentBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: accentBorder,
                                  width: 1,
                                ),
                                boxShadow: isDarkMode ? SFMSTheme.darkCardShadow : null,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.analytics_rounded,
                                    color: accentColor,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Coming Soon!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: accentColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Advanced reporting and analytics features are being developed.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}