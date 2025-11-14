import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/theme.dart';

class FinancialAccountsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const FinancialAccountsScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  State<FinancialAccountsScreen> createState() => _FinancialAccountsScreenState();
}

class _FinancialAccountsScreenState extends State<FinancialAccountsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _accounts = [];
  bool _isLoading = true;
  String? _error;
  bool _showAddAccountModal = false;

  // Form controllers
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _currentBalanceController = TextEditingController();
  String _selectedAccountType = 'savings';

  final List<Map<String, dynamic>> _accountTypes = [
    {'value': 'savings', 'label': 'Savings Account', 'icon': '💰'},
    {'value': 'checking', 'label': 'Checking Account', 'icon': '💳'},
    {'value': 'fixed_deposit', 'label': 'Fixed Deposit', 'icon': '🏦'},
    {'value': 'investment', 'label': 'Investment', 'icon': '📈'},
    {'value': 'retirement', 'label': 'Retirement', 'icon': '🏖️'},
    {'value': 'business', 'label': 'Business', 'icon': '💼'},
    {'value': 'e_wallet', 'label': 'E-Wallet', 'icon': '📱'},
    {'value': 'credit_card', 'label': 'Credit Card', 'icon': '💳'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
    _fetchAccounts();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _currentBalanceController.dispose();
    super.dispose();
  }

  Future<void> _fetchAccounts() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        _error = 'User not logged in';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await supabase
          .from('financial_accounts')
          .select()
          .eq('user_id', user.id)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      setState(() {
        _accounts = response as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load accounts: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _addAccount() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (_accountNameController.text.isEmpty ||
        _bankNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      await supabase.from('financial_accounts').insert({
        'user_id': user.id,
        'account_name': _accountNameController.text,
        'account_number': _accountNumberController.text.isNotEmpty
            ? _accountNumberController.text
            : null,
        'account_type': _selectedAccountType,
        'bank_name': _bankNameController.text,
        'current_balance': double.tryParse(_currentBalanceController.text) ?? 0.0,
        'currency': 'MYR',
        'is_active': true,
      });

      // Clear form
      _accountNameController.clear();
      _accountNumberController.clear();
      _bankNameController.clear();
      _currentBalanceController.clear();
      setState(() {
        _showAddAccountModal = false;
      });

      // Refresh accounts
      await _fetchAccounts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add account: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteAccount(String accountId) async {
    try {
      await supabase
          .from('financial_accounts')
          .update({'is_active': false})
          .eq('id', accountId);

      await _fetchAccounts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: ${e.toString()}')),
        );
      }
    }
  }

  String _getAccountTypeIcon(String type) {
    final accountType = _accountTypes.firstWhere(
          (t) => t['value'] == type,
      orElse: () => {'icon': '💰'},
    );
    return accountType['icon'];
  }

  String _getAccountTypeLabel(String type) {
    final accountType = _accountTypes.firstWhere(
          (t) => t['value'] == type,
      orElse: () => {'label': 'Account'},
    );
    return accountType['label'];
  }

  double get _totalBalance {
    return _accounts.fold(0.0, (sum, account) {
      return sum + (account['current_balance'] ?? 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final bgColor = isDarkMode ? SFMSTheme.darkBgPrimary : SFMSTheme.backgroundColor;
    final cardColor = isDarkMode ? SFMSTheme.darkCardBg : SFMSTheme.cardColor;
    final textPrimary = isDarkMode ? SFMSTheme.darkTextPrimary : SFMSTheme.textPrimary;
    final textSecondary = isDarkMode ? SFMSTheme.darkTextSecondary : SFMSTheme.textSecondary;
    final textMuted = isDarkMode ? SFMSTheme.darkTextMuted : SFMSTheme.textMuted;
    final cardShadow = isDarkMode ? SFMSTheme.darkCardShadow : SFMSTheme.softCardShadow;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
              ),
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
                            backgroundColor: cardColor.withOpacity(0.9),
                            foregroundColor: textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Financial Accounts',
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
                    child: _isLoading
                        ? Center(
                      child: CircularProgressIndicator(
                        color: isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.primaryColor,
                      ),
                    )
                        : _error != null
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 64,
                              color: SFMSTheme.dangerColor),
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: TextStyle(color: textPrimary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                        : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Total Balance Card
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 0.8 + (_animationController.value * 0.2),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDarkMode
                                          ? [SFMSTheme.accentTeal, SFMSTheme.accentEmerald]
                                          : [SFMSTheme.cartoonBlue, const Color(0xFF7BB3FF)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: cardShadow,
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        '💼',
                                        style: TextStyle(fontSize: 40),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Total Balance',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'RM ${_totalBalance.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${_accounts.length} Active Accounts',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Accounts List
                          if (_accounts.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(Icons.account_balance_wallet_outlined,
                                      size: 64,
                                      color: textMuted),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No accounts added yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add your first financial account to start tracking',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textMuted,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          else
                            ..._accounts.map((account) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: cardShadow,
                                ),
                                child: Dismissible(
                                  key: Key(account['id']),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    decoration: BoxDecoration(
                                      color: SFMSTheme.dangerColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  onDismissed: (direction) {
                                    _deleteAccount(account['id']);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: SFMSTheme.primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          child: Center(
                                            child: Text(
                                              _getAccountTypeIcon(account['account_type']),
                                              style: const TextStyle(fontSize: 24),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                account['account_name'],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${account['bank_name']} - ${_getAccountTypeLabel(account['account_type'])}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: textSecondary,
                                                ),
                                              ),
                                              if (account['account_number'] != null)
                                                Text(
                                                  'Acc: ****${account['account_number'].toString().substring(account['account_number'].toString().length - 4)}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: textMuted,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          'RM ${(account['current_balance'] ?? 0.0).toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: account['account_type'] == 'credit_card'
                                                ? SFMSTheme.dangerColor
                                                : SFMSTheme.successColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Add Account Modal
          if (_showAddAccountModal)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add New Account',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _showAddAccountModal = false),
                              icon: Icon(Icons.close, color: textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _accountNameController,
                          style: TextStyle(color: textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Account Name *',
                            labelStyle: TextStyle(color: textSecondary),
                            hintText: 'e.g., My Savings',
                            hintStyle: TextStyle(color: textMuted),
                            filled: true,
                            fillColor: isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _bankNameController,
                          style: TextStyle(color: textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Bank Name *',
                            labelStyle: TextStyle(color: textSecondary),
                            hintText: 'e.g., Maybank',
                            hintStyle: TextStyle(color: textMuted),
                            filled: true,
                            fillColor: isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _accountNumberController,
                          style: TextStyle(color: textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Account Number (Optional)',
                            labelStyle: TextStyle(color: textSecondary),
                            hintText: 'e.g., 1234567890',
                            hintStyle: TextStyle(color: textMuted),
                            filled: true,
                            fillColor: isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedAccountType,
                          style: TextStyle(color: textPrimary),
                          dropdownColor: cardColor,
                          decoration: InputDecoration(
                            labelText: 'Account Type *',
                            labelStyle: TextStyle(color: textSecondary),
                            filled: true,
                            fillColor: isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: _accountTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type['value'] as String,
                              child: Row(
                                children: [
                                  Text(type['icon'] as String, style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Text(type['label'] as String),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedAccountType = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _currentBalanceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Current Balance (RM)',
                            labelStyle: TextStyle(color: textSecondary),
                            hintText: '0.00',
                            hintStyle: TextStyle(color: textMuted),
                            filled: true,
                            fillColor: isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => setState(() => _showAddAccountModal = false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDarkMode
                                      ? SFMSTheme.darkBgTertiary
                                      : Colors.grey.shade300,
                                  foregroundColor: textPrimary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _addAccount,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SFMSTheme.successColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Add Account'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _showAddAccountModal = true),
        backgroundColor: isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}