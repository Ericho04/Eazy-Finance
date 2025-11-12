import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const ForgotPasswordScreen({
    Key? key,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    // Dark Mode Support
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Theme-aware colors
    final bgColor = isDarkMode ? SFMSTheme.darkBgPrimary : SFMSTheme.backgroundColor;
    final textPrimary = isDarkMode ? SFMSTheme.darkTextPrimary : SFMSTheme.textPrimary;
    final textSecondary = isDarkMode ? SFMSTheme.darkTextSecondary : SFMSTheme.textSecondary;
    final textMuted = isDarkMode ? SFMSTheme.darkTextMuted : SFMSTheme.textMuted;
    final cardColor = isDarkMode ? SFMSTheme.darkCardBg : Colors.white;
    final cardShadow = isDarkMode ? SFMSTheme.darkCardShadow : SFMSTheme.softCardShadow;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  SFMSTheme.darkBgPrimary,
                  SFMSTheme.darkBgSecondary,
                  SFMSTheme.darkBgTertiary,
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFDBEAFE),
                  Color(0xFFFAF5FF),
                  Color(0xFFFDF2F8),
                ],
              ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => widget.onNavigate('login'),
                      icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
                    ),
                    Expanded(
                      child: Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 40),

                // Content
                Card(
                  color: cardColor,
                  elevation: isDarkMode ? 0 : 12,
                  shadowColor: isDarkMode ? Colors.transparent : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.lock_reset,
                          size: 64,
                          color: isDarkMode ? SFMSTheme.trustPrimary : const Color(0xFF845EC2),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'Forgot Password? 🔑',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Enter your email address and we\'ll send you instructions to reset your password.',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Email Input
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: TextStyle(color: textSecondary),
                            prefixIcon: Icon(Icons.email_outlined, color: isDarkMode ? SFMSTheme.trustPrimary : null),
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(color: textMuted),
                            filled: true,
                            fillColor: isDarkMode ? SFMSTheme.darkBgPrimary : null,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
                              borderSide: BorderSide(
                                color: isDarkMode ? SFMSTheme.darkBgTertiary : const Color(0xFFE5E7EB),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
                              borderSide: BorderSide(
                                color: isDarkMode ? SFMSTheme.trustPrimary : SFMSTheme.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Send Reset Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: isDarkMode
                              ? SFMSTheme.darkTrustGradient
                              : const LinearGradient(
                                  colors: [Color(0xFF845EC2), Color(0xFFA78BFA)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                            borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
                            boxShadow: isDarkMode ? SFMSTheme.tealGlowShadow : null,
                          ),
                          child: ElevatedButton(
                            onPressed: _loading ? null : () {
                              // TODO: Implement password reset
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password reset email sent!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Send Reset Instructions',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Back to Login
                        TextButton(
                          onPressed: () => widget.onNavigate('login'),
                          child: Text(
                            'Back to Login',
                            style: TextStyle(
                              color: isDarkMode ? SFMSTheme.trustPrimary : const Color(0xFF4E8EF7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}