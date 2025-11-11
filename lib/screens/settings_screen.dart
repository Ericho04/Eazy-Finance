import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/theme.dart';

/// Modern Settings & Profile Screen
/// Redesigned with flat-vector cartoon style for fintech apps
/// Features: Profile management, security options, notifications, theme toggle
class SettingsScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const SettingsScreen({
    Key? key,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _promotionalEnabled = false;
  bool _isTwoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'User';
    final userEmail = user?.email ?? 'user@example.com';
    final userId = user?.id.substring(0, 8) ?? 'N/A';

    return Scaffold(
      backgroundColor: SFMSTheme.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Modern App Bar
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),

            // Profile Section
            SliverToBoxAdapter(
              child: _buildProfileSection(context, userName, userEmail, userId),
            ),

            // User Info Card
            SliverToBoxAdapter(
              child: _buildUserInfoCard(context, userName, userEmail, userId),
            ),

            // Security Section
            SliverToBoxAdapter(
              child: _buildSectionTitle(context, '🔒 Security & Privacy'),
            ),
            SliverToBoxAdapter(
              child: _buildSecuritySection(context),
            ),

            // Notifications Section
            SliverToBoxAdapter(
              child: _buildSectionTitle(context, '🔔 Notifications'),
            ),
            SliverToBoxAdapter(
              child: _buildNotificationsSection(context),
            ),

            // Appearance Section
            SliverToBoxAdapter(
              child: _buildSectionTitle(context, '🎨 Appearance'),
            ),
            SliverToBoxAdapter(
              child: _buildAppearanceSection(context),
            ),

            // Account Actions Section
            SliverToBoxAdapter(
              child: _buildSectionTitle(context, '⚙️ Account'),
            ),
            SliverToBoxAdapter(
              child: _buildAccountSection(context),
            ),

            // Logout Button
            SliverToBoxAdapter(
              child: _buildLogoutButton(context),
            ),

            // Bottom Spacing
            SliverToBoxAdapter(
              child: SizedBox(height: SFMSTheme.spacing32),
            ),
          ],
        ),
      ),
    );
  }

  /// Header with title and back button
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SFMSTheme.spacing20),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => widget.onNavigate('dashboard'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: SFMSTheme.cardColor,
                borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
                boxShadow: SFMSTheme.softCardShadow,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: SFMSTheme.primaryColor,
                size: SFMSTheme.iconSizeLarge,
              ),
            ),
          ),
          SizedBox(width: SFMSTheme.spacing16),
          // Title
          Text(
            'Settings & Profile',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  /// Profile Avatar Section with edit button
  Widget _buildProfileSection(
      BuildContext context, String name, String email, String id) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SFMSTheme.spacing20),
      child: Column(
        children: [
          // Avatar with gradient border
          Stack(
            alignment: Alignment.center,
            children: [
              // Gradient Border
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: SFMSTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: SFMSTheme.cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          gradient: SFMSTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(name),
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Edit Button
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    _showImageUploadDialog(context);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: SFMSTheme.accentGradient,
                      shape: BoxShape.circle,
                      boxShadow: SFMSTheme.accentShadow(SFMSTheme.accentColor),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: SFMSTheme.iconSizeMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: SFMSTheme.spacing16),
          // Name
          Text(
            name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: SFMSTheme.spacing4),
          // Email
          Text(
            email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SFMSTheme.textSecondary,
                ),
          ),
          SizedBox(height: SFMSTheme.spacing24),
        ],
      ),
    );
  }

  /// User Info Card with name, email, and account ID
  Widget _buildUserInfoCard(
      BuildContext context, String name, String email, String id) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SFMSTheme.spacing20,
        vertical: SFMSTheme.spacing8,
      ),
      child: Container(
        padding: EdgeInsets.all(SFMSTheme.spacing20),
        decoration: BoxDecoration(
          color: SFMSTheme.cardColor,
          borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
          boxShadow: SFMSTheme.softCardShadow,
        ),
        child: Column(
          children: [
            _buildInfoRow(
              context,
              icon: Icons.person_outline_rounded,
              label: 'Full Name',
              value: name,
              iconGradient: SFMSTheme.primaryGradient,
            ),
            Divider(height: SFMSTheme.spacing24),
            _buildInfoRow(
              context,
              icon: Icons.email_outlined,
              label: 'Email Address',
              value: email,
              iconGradient: SFMSTheme.cartoonBlueGradient,
            ),
            Divider(height: SFMSTheme.spacing24),
            _buildInfoRow(
              context,
              icon: Icons.fingerprint_rounded,
              label: 'Account ID',
              value: id.toUpperCase(),
              iconGradient: SFMSTheme.cartoonPurpleGradient,
            ),
          ],
        ),
      ),
    );
  }

  /// Info row with icon, label, and value
  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required LinearGradient iconGradient,
  }) {
    return Row(
      children: [
        // Icon with gradient background
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: iconGradient,
            borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: SFMSTheme.iconSizeMedium,
          ),
        ),
        SizedBox(width: SFMSTheme.spacing16),
        // Label and Value
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SFMSTheme.textSecondary,
                    ),
              ),
              SizedBox(height: SFMSTheme.spacing4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Section title with emoji
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        SFMSTheme.spacing20,
        SFMSTheme.spacing24,
        SFMSTheme.spacing20,
        SFMSTheme.spacing12,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  /// Security & Privacy Section
  Widget _buildSecuritySection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SFMSTheme.spacing20),
      child: Container(
        decoration: BoxDecoration(
          color: SFMSTheme.cardColor,
          borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
          boxShadow: SFMSTheme.softCardShadow,
        ),
        child: Column(
          children: [
            _buildSettingsItem(
              context,
              icon: Icons.lock_outline_rounded,
              title: 'Change Password',
              subtitle: 'Update your account password',
              iconGradient: SFMSTheme.cartoonOrangeGradient,
              onTap: () {
                _showChangePasswordDialog(context);
              },
            ),
            Divider(height: 1, indent: 76, endIndent: 20),
            _buildSettingsItemWithToggle(
              context,
              icon: Icons.security_rounded,
              title: 'Two-Factor Authentication',
              subtitle: _isTwoFactorEnabled ? 'Enabled' : 'Disabled',
              iconGradient: SFMSTheme.successGradient,
              value: _isTwoFactorEnabled,
              onChanged: (value) {
                setState(() {
                  _isTwoFactorEnabled = value;
                });
                _show2FADialog(context, value);
              },
            ),
            Divider(height: 1, indent: 76, endIndent: 20),
            _buildSettingsItem(
              context,
              icon: Icons.devices_rounded,
              title: 'Manage Devices',
              subtitle: 'View and manage logged-in devices',
              iconGradient: SFMSTheme.cartoonCyanGradient,
              onTap: () {
                _showManageDevicesDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Notifications Section with toggle switches
  Widget _buildNotificationsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SFMSTheme.spacing20),
      child: Container(
        decoration: BoxDecoration(
          color: SFMSTheme.cardColor,
          borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
          boxShadow: SFMSTheme.softCardShadow,
        ),
        child: Column(
          children: [
            _buildSettingsItemWithToggle(
              context,
              icon: Icons.notifications_active_outlined,
              title: 'App Notifications',
              subtitle: 'Receive alerts for transactions',
              iconGradient: SFMSTheme.cartoonPurpleGradient,
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            Divider(height: 1, indent: 76, endIndent: 20),
            _buildSettingsItemWithToggle(
              context,
              icon: Icons.campaign_outlined,
              title: 'Promotional Messages',
              subtitle: 'Get updates on new features',
              iconGradient: SFMSTheme.cartoonPinkGradient,
              value: _promotionalEnabled,
              onChanged: (value) {
                setState(() {
                  _promotionalEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Appearance Section with theme toggle
  Widget _buildAppearanceSection(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SFMSTheme.spacing20),
      child: Container(
        padding: EdgeInsets.all(SFMSTheme.spacing20),
        decoration: BoxDecoration(
          color: SFMSTheme.cardColor,
          borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
          boxShadow: SFMSTheme.softCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon with gradient
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: isDarkMode
                        ? SFMSTheme.cartoonPurpleGradient
                        : SFMSTheme.cartoonYellowGradient,
                    borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
                  ),
                  child: Icon(
                    isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                    color: Colors.white,
                    size: SFMSTheme.iconSizeLarge,
                  ),
                ),
                SizedBox(width: SFMSTheme.spacing16),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme Mode',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: SFMSTheme.spacing4),
                      Text(
                        isDarkMode ? 'Dark Mode' : 'Light Mode',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: SFMSTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: SFMSTheme.spacing16),
            // Theme Toggle with cartoon sun/moon
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: SFMSTheme.neutralLight,
                borderRadius: BorderRadius.circular(SFMSTheme.radiusLarge),
              ),
              child: Row(
                children: [
                  // Light Mode Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (isDarkMode) {
                          themeProvider.setThemeMode(ThemeMode.light);
                        }
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: !isDarkMode ? SFMSTheme.cartoonYellowGradient : null,
                          borderRadius: BorderRadius.circular(SFMSTheme.radiusLarge),
                          boxShadow: !isDarkMode
                              ? SFMSTheme.accentShadow(SFMSTheme.cartoonYellow)
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '☀️',
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(width: SFMSTheme.spacing8),
                            Text(
                              'Light',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: !isDarkMode
                                        ? Colors.white
                                        : SFMSTheme.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: SFMSTheme.spacing8),
                  // Dark Mode Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!isDarkMode) {
                          themeProvider.setThemeMode(ThemeMode.dark);
                        }
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: isDarkMode ? SFMSTheme.cartoonPurpleGradient : null,
                          borderRadius: BorderRadius.circular(SFMSTheme.radiusLarge),
                          boxShadow: isDarkMode
                              ? SFMSTheme.accentShadow(SFMSTheme.cartoonPurple)
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '🌙',
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(width: SFMSTheme.spacing8),
                            Text(
                              'Dark',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: isDarkMode
                                        ? Colors.white
                                        : SFMSTheme.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Account Section
  Widget _buildAccountSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SFMSTheme.spacing20),
      child: Container(
        decoration: BoxDecoration(
          color: SFMSTheme.cardColor,
          borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
          boxShadow: SFMSTheme.softCardShadow,
        ),
        child: Column(
          children: [
            _buildSettingsItem(
              context,
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              subtitle: 'Get help with your account',
              iconGradient: SFMSTheme.infoGradient,
              onTap: () {
                _showHelpDialog(context);
              },
            ),
            Divider(height: 1, indent: 76, endIndent: 20),
            _buildSettingsItem(
              context,
              icon: Icons.description_outlined,
              title: 'Terms & Privacy',
              subtitle: 'Read our terms and privacy policy',
              iconGradient: SFMSTheme.cartoonCyanGradient,
              onTap: () {
                _showTermsDialog(context);
              },
            ),
            Divider(height: 1, indent: 76, endIndent: 20),
            _buildSettingsItem(
              context,
              icon: Icons.info_outline_rounded,
              title: 'About',
              subtitle: 'Version 1.0.0 - Eazy Finance',
              iconGradient: SFMSTheme.cartoonMintGradient,
              onTap: () {
                _showAboutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Settings item with arrow
  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient iconGradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
      child: Padding(
        padding: EdgeInsets.all(SFMSTheme.spacing16),
        child: Row(
          children: [
            // Icon with gradient background
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: iconGradient,
                borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: SFMSTheme.iconSizeMedium,
              ),
            ),
            SizedBox(width: SFMSTheme.spacing16),
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: SFMSTheme.spacing4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SFMSTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: SFMSTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  /// Settings item with toggle switch
  Widget _buildSettingsItemWithToggle(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient iconGradient,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.all(SFMSTheme.spacing16),
      child: Row(
        children: [
          // Icon with gradient background
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: iconGradient,
              borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: SFMSTheme.iconSizeMedium,
            ),
          ),
          SizedBox(width: SFMSTheme.spacing16),
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: SFMSTheme.spacing4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SFMSTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          // Toggle Switch
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: SFMSTheme.successColor,
            activeTrackColor: SFMSTheme.successColor.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  /// Modern Logout Button with gradient
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SFMSTheme.spacing20,
        vertical: SFMSTheme.spacing16,
      ),
      child: GestureDetector(
        onTap: () async {
          final confirmed = await _showLogoutConfirmation(context);
          if (confirmed == true) {
            try {
              await Provider.of<AuthProvider>(context, listen: false).signOut();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error logging out: $e'),
                    backgroundColor: SFMSTheme.dangerColor,
                  ),
                );
              }
            }
          }
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: SFMSTheme.dangerGradient,
            borderRadius: BorderRadius.circular(SFMSTheme.radiusLarge),
            boxShadow: SFMSTheme.accentShadow(SFMSTheme.dangerColor),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: SFMSTheme.iconSizeMedium,
                ),
                SizedBox(width: SFMSTheme.spacing12),
                Text(
                  'Logout',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /// Get user initials from name
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  // ==========================================================================
  // DIALOG METHODS
  // ==========================================================================

  /// Show logout confirmation dialog
  Future<bool?> _showLogoutConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(SFMSTheme.spacing8),
              decoration: BoxDecoration(
                color: SFMSTheme.dangerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: SFMSTheme.dangerColor,
                size: SFMSTheme.iconSizeLarge,
              ),
            ),
            SizedBox(width: SFMSTheme.spacing12),
            Text('Logout'),
          ],
        ),
        content: Text(
          'Are you sure you want to logout from your account?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: SFMSTheme.dangerColor,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  /// Show image upload dialog
  void _showImageUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(SFMSTheme.spacing8),
              decoration: BoxDecoration(
                gradient: SFMSTheme.accentGradient,
                borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: SFMSTheme.iconSizeLarge,
              ),
            ),
            SizedBox(width: SFMSTheme.spacing12),
            Text('Change Profile Photo'),
          ],
        ),
        content: Text(
          'Photo upload feature coming soon! You\'ll be able to upload a custom profile picture.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Show change password dialog
  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(SFMSTheme.spacing8),
              decoration: BoxDecoration(
                gradient: SFMSTheme.cartoonOrangeGradient,
                borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                color: Colors.white,
                size: SFMSTheme.iconSizeLarge,
              ),
            ),
            SizedBox(width: SFMSTheme.spacing12),
            Text('Change Password'),
          ],
        ),
        content: Text(
          'Password change feature coming soon! You\'ll be able to update your password securely.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Show 2FA dialog
  void _show2FADialog(BuildContext context, bool enabled) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(SFMSTheme.spacing8),
              decoration: BoxDecoration(
                gradient: SFMSTheme.successGradient,
                borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
              ),
              child: Icon(
                Icons.security_rounded,
                color: Colors.white,
                size: SFMSTheme.iconSizeLarge,
              ),
            ),
            SizedBox(width: SFMSTheme.spacing12),
            Text('Two-Factor Auth'),
          ],
        ),
        content: Text(
          enabled
              ? '2FA enabled! Your account is now more secure with two-factor authentication.'
              : '2FA setup feature coming soon! You\'ll be able to enable two-factor authentication for extra security.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Show manage devices dialog
  void _showManageDevicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(SFMSTheme.spacing8),
              decoration: BoxDecoration(
                gradient: SFMSTheme.cartoonCyanGradient,
                borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
              ),
              child: Icon(
                Icons.devices_rounded,
                color: Colors.white,
                size: SFMSTheme.iconSizeLarge,
              ),
            ),
            SizedBox(width: SFMSTheme.spacing12),
            Text('Manage Devices'),
          ],
        ),
        content: Text(
          'Device management feature coming soon! You\'ll be able to see all logged-in devices and manage them.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Show help dialog
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(SFMSTheme.spacing8),
              decoration: BoxDecoration(
                gradient: SFMSTheme.infoGradient,
                borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
              ),
              child: Icon(
                Icons.help_outline_rounded,
                color: Colors.white,
                size: SFMSTheme.iconSizeLarge,
              ),
            ),
            SizedBox(width: SFMSTheme.spacing12),
            Text('Help & Support'),
          ],
        ),
        content: Text(
          'Need help? Contact us at support@eazyfinance.com or visit our help center.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Show terms dialog
  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(SFMSTheme.spacing8),
              decoration: BoxDecoration(
                gradient: SFMSTheme.cartoonCyanGradient,
                borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
              ),
              child: Icon(
                Icons.description_outlined,
                color: Colors.white,
                size: SFMSTheme.iconSizeLarge,
              ),
            ),
            SizedBox(width: SFMSTheme.spacing12),
            Text('Terms & Privacy'),
          ],
        ),
        content: Text(
          'Visit eazyfinance.com/terms and eazyfinance.com/privacy to read our full terms of service and privacy policy.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Show about dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(SFMSTheme.spacing8),
              decoration: BoxDecoration(
                gradient: SFMSTheme.cartoonMintGradient,
                borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
                size: SFMSTheme.iconSizeLarge,
              ),
            ),
            SizedBox(width: SFMSTheme.spacing12),
            Text('About'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eazy Finance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: SFMSTheme.spacing8),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SFMSTheme.textSecondary,
                  ),
            ),
            SizedBox(height: SFMSTheme.spacing16),
            Text(
              'A modern, trustworthy fintech app for managing your finances with ease.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
