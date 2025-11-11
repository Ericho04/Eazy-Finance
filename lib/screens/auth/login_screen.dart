import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme.dart';

class LoginScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const LoginScreen({
    Key? key,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _loading = false;

  late AnimationController _logoController;
  late AnimationController _cardController;
  late Animation<double> _logoAnimation;
  late Animation<Offset> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _cardAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardController.forward();
    });
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      return;
    }

    setState(() => _loading = true);

    try {
      final success = await context.read<AuthProvider>().signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invalid email or password'),
            backgroundColor: SFMSTheme.dangerColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
            ),
          ),
        );
      }
    } catch (e) {
      print('Login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: SFMSTheme.dangerColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
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
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  SFMSTheme.backgroundVariant,
                  SFMSTheme.backgroundColor,
                  SFMSTheme.aiLight,
                ],
              ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(SFMSTheme.spacing24),
            child: Column(
              children: [
                SizedBox(height: SFMSTheme.spacing40),

                // App Logo and Title with theme gradient
                ScaleTransition(
                  scale: _logoAnimation,
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SFMSTheme.primaryGradient,
                          boxShadow: SFMSTheme.accentShadow(SFMSTheme.primaryColor),
                        ),
                        child: Icon(
                          Icons.trending_up,
                          color: Colors.white,
                          size: SFMSTheme.iconSizeHero,
                        ),
                      ),
                      SizedBox(height: SFMSTheme.spacing24),
                      Text(
                        'SFMS',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: SFMSTheme.spacing8),
                      Text(
                        'Smart Finance Management System',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: SFMSTheme.spacing48),

                // Login Card with modern styling
                SlideTransition(
                  position: _cardAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
                      boxShadow: cardShadow,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(SFMSTheme.spacing32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Welcome Text
                          Text(
                            'Welcome Back! 👋',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: SFMSTheme.spacing8),
                          Text(
                            'Sign in to continue your financial journey',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: textSecondary,
                                ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: SFMSTheme.spacing32),

                          // Email Input
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: TextStyle(color: textSecondary),
                              prefixIcon: Icon(Icons.email, color: isDarkMode ? SFMSTheme.trustPrimary : SFMSTheme.primaryColor),
                              filled: true,
                              fillColor: isDarkMode ? SFMSTheme.darkBgSecondary : SFMSTheme.neutralLight,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
                                borderSide: BorderSide(
                                  color: isDarkMode ? SFMSTheme.darkBgTertiary : SFMSTheme.neutralMedium,
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

                          SizedBox(height: SFMSTheme.spacing16),

                          // Password Input
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            style: TextStyle(color: textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: textSecondary),
                              prefixIcon: Icon(Icons.lock, color: isDarkMode ? SFMSTheme.trustPrimary : SFMSTheme.primaryColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: textSecondary,
                                ),
                                onPressed: () =>
                                    setState(() => _showPassword = !_showPassword),
                              ),
                              filled: true,
                              fillColor: isDarkMode ? SFMSTheme.darkBgSecondary : SFMSTheme.neutralLight,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
                                borderSide: BorderSide(
                                  color: isDarkMode ? SFMSTheme.darkBgTertiary : SFMSTheme.neutralMedium,
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

                          SizedBox(height: SFMSTheme.spacing24),

                          // Login Button with gradient
                          Container(
                            decoration: BoxDecoration(
                              gradient: isDarkMode ? SFMSTheme.darkTrustGradient : SFMSTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
                              boxShadow: isDarkMode ? SFMSTheme.tealGlowShadow : SFMSTheme.accentShadow(SFMSTheme.primaryColor),
                            ),
                            child: ElevatedButton(
                              onPressed: _loading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(
                                  vertical: SFMSTheme.spacing16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(SFMSTheme.radiusMedium),
                                ),
                              ),
                              child: _loading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.login,
                                            size: SFMSTheme.iconSizeMedium),
                                        SizedBox(width: SFMSTheme.spacing8),
                                        Text(
                                          'Sign In to SFMS',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: Colors.white,
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

                SizedBox(height: SFMSTheme.spacing24),

                // Footer Links
                TextButton(
                  onPressed: () => widget.onNavigate('forgot-password'),
                  child: Text(
                    'Forgot your password?',
                    style: TextStyle(
                      color: isDarkMode ? SFMSTheme.trustPrimary : SFMSTheme.aiPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: SFMSTheme.spacing8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: TextStyle(color: textSecondary),
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigate('signup'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        'Sign up here',
                        style: TextStyle(
                          color: isDarkMode ? SFMSTheme.trustPrimary : SFMSTheme.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: SFMSTheme.spacing40),

                // Feature Highlights with theme colors
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFeatureHighlight(
                        '📊', 'Smart\nAnalytics', SFMSTheme.cartoonBlue),
                    _buildFeatureHighlight(
                        '🎯', 'Goal\nTracking', SFMSTheme.cartoonPurple),
                    _buildFeatureHighlight(
                        '💰', 'Budget\nControl', SFMSTheme.cartoonTeal),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureHighlight(String emoji, String title, Color color) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final textSecondary = isDarkMode ? SFMSTheme.darkTextSecondary : SFMSTheme.textSecondary;

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(isDarkMode ? 0.3 : 0.2),
                color.withOpacity(isDarkMode ? 0.15 : 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
            border: Border.all(
              color: color.withOpacity(isDarkMode ? 0.4 : 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        SizedBox(height: SFMSTheme.spacing8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _cardController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
