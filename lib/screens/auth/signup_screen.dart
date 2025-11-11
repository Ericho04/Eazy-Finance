import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme.dart';

class SignupScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const SignupScreen({
    Key? key,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _loading = false;
  bool _acceptedTerms = false;
  
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final success = await context.read<AuthProvider>().signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _fullNameController.text.trim(),
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigation will be handled by auth state change
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create account'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
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
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => widget.onNavigate('login'),
                        icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
                      ),
                      Expanded(
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Welcome Text
                  Text(
                    'Join SFMS Today! 🚀',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? SFMSTheme.trustPrimary : const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your journey to financial freedom',
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Signup Form
                  Card(
                    color: cardColor,
                    elevation: isDarkMode ? 0 : 12,
                    shadowColor: isDarkMode ? Colors.transparent : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Full Name
                            TextFormField(
                              controller: _fullNameController,
                              validator: (value) =>
                                  value?.isEmpty == true ? 'Full name is required' : null,
                              style: TextStyle(color: textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                labelStyle: TextStyle(color: textSecondary),
                                prefixIcon: Icon(Icons.person_outline, color: isDarkMode ? SFMSTheme.trustPrimary : null),
                                hintText: 'Enter your full name',
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

                            const SizedBox(height: 16),

                            // Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
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

                            const SizedBox(height: 16),

                            // Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_showPassword,
                              validator: _validatePassword,
                              style: TextStyle(color: textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(color: textSecondary),
                                prefixIcon: Icon(Icons.lock_outline, color: isDarkMode ? SFMSTheme.trustPrimary : null),
                                hintText: 'Enter your password',
                                hintStyle: TextStyle(color: textMuted),
                                filled: true,
                                fillColor: isDarkMode ? SFMSTheme.darkBgPrimary : null,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showPassword ? Icons.visibility_off : Icons.visibility,
                                    color: textSecondary,
                                  ),
                                  onPressed: () => setState(() => _showPassword = !_showPassword),
                                ),
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

                            const SizedBox(height: 16),

                            // Confirm Password
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: !_showConfirmPassword,
                              validator: _validateConfirmPassword,
                              style: TextStyle(color: textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                labelStyle: TextStyle(color: textSecondary),
                                prefixIcon: Icon(Icons.lock_outline, color: isDarkMode ? SFMSTheme.trustPrimary : null),
                                hintText: 'Confirm your password',
                                hintStyle: TextStyle(color: textMuted),
                                filled: true,
                                fillColor: isDarkMode ? SFMSTheme.darkBgPrimary : null,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                    color: textSecondary,
                                  ),
                                  onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                                ),
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
                            
                            // Terms & Conditions
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _acceptedTerms,
                                  onChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                                  activeColor: isDarkMode ? SFMSTheme.trustPrimary : const Color(0xFF2E7D32),
                                  checkColor: Colors.white,
                                  side: BorderSide(
                                    color: isDarkMode ? SFMSTheme.darkBgTertiary : const Color(0xFF6B7280),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                                    child: Text(
                                      'I agree to the Terms & Conditions and Privacy Policy',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Signup Button
                            Container(
                              decoration: BoxDecoration(
                                gradient: isDarkMode ? SFMSTheme.darkTrustGradient : SFMSTheme.successGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: isDarkMode ? SFMSTheme.tealGlowShadow : null,
                              ),
                              child: ElevatedButton(
                                onPressed: _loading ? null : _handleSignup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
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
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.person_add),
                                          SizedBox(width: 8),
                                          Text(
                                            'Create Account',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
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
                  
                  const SizedBox(height: 24),
                  
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: textSecondary),
                      ),
                      TextButton(
                        onPressed: () => widget.onNavigate('login'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            color: isDarkMode ? SFMSTheme.trustPrimary : const Color(0xFF4E8EF7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Benefits
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDarkMode
                        ? SFMSTheme.darkCardBg.withOpacity(0.6)
                        : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDarkMode
                          ? SFMSTheme.darkBgTertiary.withOpacity(0.5)
                          : Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Why join SFMS? ✨',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? SFMSTheme.trustPrimary : const Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildBenefitItem('📊', 'Smart Analytics', 'AI-powered financial insights'),
                        _buildBenefitItem('🎯', 'Goal Tracking', 'Achieve your financial dreams'),
                        _buildBenefitItem('🏆', 'Gamification', 'Lucky draws & reward system'),
                        _buildBenefitItem('🔒', 'Secure & Private', 'Your data is protected'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String emoji, String title, String subtitle) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final textPrimary = isDarkMode ? SFMSTheme.darkTextPrimary : SFMSTheme.textPrimary;
    final textSecondary = isDarkMode ? SFMSTheme.darkTextSecondary : SFMSTheme.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDarkMode
                ? SFMSTheme.trustPrimary.withOpacity(0.2)
                : const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}