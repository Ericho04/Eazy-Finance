import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/theme_provider.dart';
import '../utils/theme.dart';
import '../providers/theme_provider.dart';

class FinancialScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const FinancialScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<FinancialScreen> createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<FinancialScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animationController.forward();
    _floatingController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Theme-aware colors
    final bgColor = isDarkMode ? SFMSTheme.darkBgPrimary : SFMSTheme.backgroundColor;
    final cardBg = isDarkMode ? SFMSTheme.darkBgSecondary : SFMSTheme.cardColor;
    final textPrimary = isDarkMode ? SFMSTheme.darkTextPrimary : SFMSTheme.textPrimary;
    final textSecondary = isDarkMode ? SFMSTheme.darkTextSecondary : SFMSTheme.textSecondary;

    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // Header
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -50 * (1 - _animationController.value)),
                  child: Opacity(
                    opacity: _animationController.value,
                    child: Row(
                      children: [
                        AnimatedBuilder(
                          animation: _floatingController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: math.sin(_floatingController.value * 2 * math.pi) * 0.1,
                              child: const Text(
                                '💰',
                                style: TextStyle(fontSize: 40),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Financial Tools',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
          
          // Financial Tools Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: _financialTools.length,
            itemBuilder: (context, index) {
              final tool = _financialTools[index];
              return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (50 + index * 20) * (1 - _animationController.value)),
                    child: Opacity(
                      opacity: _animationController.value,
                      child: GestureDetector(
                        onTap: () => widget.onNavigate(tool.route),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: tool.colors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: isDarkMode
                                ? SFMSTheme.darkCardGlow
                                : [
                                    BoxShadow(
                                      color: tool.colors.first.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                          ),
                          child: Stack(
                            children: [
                              // Background decoration
                              Positioned(
                                top: -20,
                                right: -20,
                                child: Opacity(
                                  opacity: 0.2,
                                  child: Icon(
                                    tool.icon,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              
                              // Content
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          tool.icon,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          tool.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      tool.description,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Coming soon badge (if applicable)
                              if (tool.isComingSoon)
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Soon',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: tool.colors.first,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),
          
          // Quick Stats Card
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 100 * (1 - _animationController.value)),
                child: Opacity(
                  opacity: _animationController.value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: isDarkMode
                          ? LinearGradient(
                              colors: [cardBg, cardBg.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Colors.white, Color(0xFFFAF5FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isDarkMode ? SFMSTheme.darkCardGlow : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [SFMSTheme.aiColor, SFMSTheme.aiColor.withOpacity(0.8)],
                                ),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Center(
                                child: Text('🤖', style: TextStyle(fontSize: 24)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AI Financial Insights',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Smart recommendations for your finances',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? SFMSTheme.accentTeal.withOpacity(0.1)
                                : SFMSTheme.aiLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDarkMode
                                  ? SFMSTheme.accentTeal.withOpacity(0.3)
                                  : SFMSTheme.aiColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '💡 Smart Tip',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Based on your spending patterns, consider setting up automatic savings to reach your financial goals faster!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textSecondary,
                                  height: 1.4,
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
            },
          ),
          const SizedBox(height: 24),
          
          // Coming Soon Features
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [
                        SFMSTheme.accentTeal.withOpacity(0.1),
                        SFMSTheme.accentEmerald.withOpacity(0.1),
                      ]
                    : [
                        SFMSTheme.cartoonYellow.withOpacity(0.1),
                        SFMSTheme.cartoonOrange.withOpacity(0.1),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDarkMode
                    ? SFMSTheme.accentTeal.withOpacity(0.3)
                    : SFMSTheme.cartoonYellow.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _floatingController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + math.sin(_floatingController.value * 2 * math.pi) * 0.05,
                      child: const Text('🚀', style: TextStyle(fontSize: 50)),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'More Features Coming Soon!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'re working hard to bring you more powerful financial management tools.',
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 100), // Extra padding for bottom navigation
          ],
        ),
      ),
    );
  }
}

class FinancialTool {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> colors;
  final String route;
  final bool isComingSoon;

  FinancialTool({
    required this.title,
    required this.description,
    required this.icon,
    required this.colors,
    required this.route,
    this.isComingSoon = false,
  });
}

final List<FinancialTool> _financialTools = [
  FinancialTool(
    title: 'Debt Manager',
    description: 'Track and manage your debts effectively',
    icon: Icons.credit_card_rounded,
    colors: [SFMSTheme.dangerColor, const Color(0xFFFF8A65)],
    route: 'financial-debts',
    isComingSoon: true,
  ),
  FinancialTool(
    title: 'Accounts',
    description: 'Manage your bank accounts and cards',
    icon: Icons.account_balance_rounded,
    colors: [SFMSTheme.cartoonBlue, const Color(0xFF7BB3FF)],
    route: 'financial-accounts',
    isComingSoon: true,
  ),
  FinancialTool(
    title: 'Financial Goals',
    description: 'Set and track your financial targets',
    icon: Icons.flag_rounded,
    colors: [SFMSTheme.successColor, const Color(0xFF81C784)],
    route: 'financial-goals',
    isComingSoon: true,
  ),
  FinancialTool(
    title: 'Tax Planning',
    description: 'Plan and organize your tax obligations',
    icon: Icons.receipt_long_rounded,
    colors: [SFMSTheme.cartoonPurple, const Color(0xFFB39BC8)],
    route: 'financial-tax',
    isComingSoon: true,
  ),
];