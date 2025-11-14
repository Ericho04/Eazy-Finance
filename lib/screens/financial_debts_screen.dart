import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/theme.dart';
import '../providers/theme_provider.dart';

class FinancialDebtsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const FinancialDebtsScreen({
    Key? key,
    required this.onBack,
  }) : super(key: key);

  @override
  State<FinancialDebtsScreen> createState() => _FinancialDebtsScreenState();
}

class _FinancialDebtsScreenState extends State<FinancialDebtsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _paymentController;
  final supabase = Supabase.instance.client;

  bool _showAddDebtModal = false;
  bool _showPaymentModal = false;
  String? _selectedDebtId;
  bool _isLoading = true;
  String? _error;

  final _debtNameController = TextEditingController();
  final _debtAmountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _paymentAmountController = TextEditingController();
  final _creditorNameController = TextEditingController();
  final _minimumPaymentController = TextEditingController();

  String _selectedDebtType = 'credit_card';

  final List<Map<String, dynamic>> _debtTypes = [
    {'value': 'credit_card', 'label': 'Credit Card', 'icon': '💳'},
    {'value': 'personal_loan', 'label': 'Personal Loan', 'icon': '🏦'},
    {'value': 'car_loan', 'label': 'Car Loan', 'icon': '🚗'},
    {'value': 'home_loan', 'label': 'Home Loan', 'icon': '🏠'},
    {'value': 'student_loan', 'label': 'Student Loan', 'icon': '🎓'},
    {'value': 'business_loan', 'label': 'Business Loan', 'icon': '🏢'},
    {'value': 'other', 'label': 'Other', 'icon': '💰'},
  ];

  List<Map<String, dynamic>> _debts = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _paymentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animationController.forward();
    _fetchDebts();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _paymentController.dispose();
    _debtNameController.dispose();
    _debtAmountController.dispose();
    _interestRateController.dispose();
    _paymentAmountController.dispose();
    _creditorNameController.dispose();
    _minimumPaymentController.dispose();
    super.dispose();
  }

  Future<void> _fetchDebts() async {
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
          .from('financial_debts')
          .select()
          .eq('user_id', user.id)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      setState(() {
        _debts = response as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load debts: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _addDebt() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (_debtNameController.text.isEmpty ||
        _debtAmountController.text.isEmpty ||
        _creditorNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      final originalAmount = double.parse(_debtAmountController.text);

      await supabase.from('financial_debts').insert({
        'user_id': user.id,
        'debt_name': _debtNameController.text,
        'debt_type': _selectedDebtType,
        'original_amount': originalAmount,
        'current_balance': originalAmount,
        'interest_rate': double.tryParse(_interestRateController.text) ?? 0.0,
        'minimum_payment': double.tryParse(_minimumPaymentController.text) ??
            (originalAmount * 0.03), // Default 3% of balance
        'creditor_name': _creditorNameController.text,
        'due_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'is_active': true,
      });

      // Clear form
      _debtNameController.clear();
      _debtAmountController.clear();
      _interestRateController.clear();
      _creditorNameController.clear();
      _minimumPaymentController.clear();

      setState(() {
        _showAddDebtModal = false;
      });

      await _fetchDebts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debt added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add debt: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _makePayment(String debtId, double amount) async {
    try {
      // Get current debt details
      final debt = _debts.firstWhere((d) => d['id'] == debtId);
      final newBalance = math.max(0.0, (debt['current_balance'] ?? 0.0) - amount);

      // Update in Supabase
      await supabase
          .from('financial_debts')
          .update({
        'current_balance': newBalance,
        'last_payment_date': DateTime.now().toIso8601String(),
      })
          .eq('id', debtId);

      setState(() {
        _showPaymentModal = false;
      });
      _paymentAmountController.clear();

      await _fetchDebts();

      _paymentController.forward().then((_) => _paymentController.reset());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newBalance == 0
                ? '🎉 Debt paid off completely!'
                : 'Payment of RM ${amount.toStringAsFixed(2)} successful!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to make payment: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteDebt(String debtId) async {
    try {
      await supabase
          .from('financial_debts')
          .update({'is_active': false})
          .eq('id', debtId);

      await _fetchDebts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debt deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete debt: ${e.toString()}')),
        );
      }
    }
  }

  double get _totalDebt {
    return _debts.fold(0.0, (sum, debt) => sum + (debt['current_balance'] ?? 0.0));
  }

  double get _totalMinPayment {
    return _debts.fold(0.0, (sum, debt) => sum + (debt['minimum_payment'] ?? 0.0));
  }

  String _getDebtTypeEmoji(String type) {
    final debtType = _debtTypes.firstWhere(
          (t) => t['value'] == type,
      orElse: () => {'icon': '💰'},
    );
    return debtType['icon'];
  }

  String _getDebtTypeLabel(String type) {
    final debtType = _debtTypes.firstWhere(
          (t) => t['value'] == type,
      orElse: () => {'label': 'Debt'},
    );
    return debtType['label'];
  }

  Color _getDebtStatusColor(BuildContext context, double currentBalance, double totalAmount) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    final percentage = currentBalance / totalAmount;
    if (percentage > 0.7) {
      return isDarkMode ? SFMSTheme.darkAccentCoral : Colors.red;
    }
    if (percentage > 0.4) {
      return Colors.orange;
    }
    return isDarkMode ? SFMSTheme.darkAccentEmerald : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final bgColor = isDarkMode ? SFMSTheme.darkBgPrimary : SFMSTheme.backgroundColor;
    final textPrimary = isDarkMode ? SFMSTheme.darkTextPrimary : SFMSTheme.textPrimary;
    final textSecondary = isDarkMode ? SFMSTheme.darkTextSecondary : SFMSTheme.textSecondary;
    final textMuted = isDarkMode ? SFMSTheme.darkTextMuted : SFMSTheme.textMuted;
    final cardColor = isDarkMode ? SFMSTheme.darkCardBg : SFMSTheme.cardColor;
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
                  Color(0xFFFFDBDB),
                  Color(0xFFFFF5F5),
                  Color(0xFFFDF2F8),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(context, isDarkMode, cardColor, textPrimary),

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
                          Text(_error!,
                              style: TextStyle(color: textPrimary),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    )
                        : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // Summary Cards
                          _buildSummaryCards(context, isDarkMode, cardColor, textPrimary, textSecondary, cardShadow),
                          const SizedBox(height: 24),

                          // Debts List
                          if (_debts.isEmpty)
                            _buildEmptyState(textSecondary, textMuted)
                          else
                            _buildDebtsList(context, isDarkMode, cardColor, textPrimary, textSecondary, textMuted, cardShadow),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Add Debt Modal
          if (_showAddDebtModal)
            _buildAddDebtModal(context, isDarkMode, cardColor, textPrimary, textSecondary, textMuted),

          // Payment Modal
          if (_showPaymentModal && _selectedDebtId != null)
            _buildPaymentModal(context, isDarkMode, cardColor, textPrimary, textSecondary, textMuted),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _showAddDebtModal = true),
        backgroundColor: isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode, Color cardColor, Color textPrimary) {
    return Padding(
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
            'Debt Manager',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, bool isDarkMode, Color cardColor,
      Color textPrimary, Color textSecondary, List<BoxShadow> cardShadow) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [SFMSTheme.dangerColor, const Color(0xFFFF8A65)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.trending_down_rounded,
                    color: Colors.white, size: 28),
                const SizedBox(height: 12),
                const Text(
                  'Total Debt',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'RM ${_totalDebt.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.calendar_today_rounded,
                    color: Colors.white, size: 28),
                const SizedBox(height: 12),
                const Text(
                  'Min. Payment',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'RM ${_totalMinPayment.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Color textSecondary, Color textMuted) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.celebration_outlined, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            'No Debts!',
            style: TextStyle(
              fontSize: 18,
              color: textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Great job! You\'re debt-free.',
            style: TextStyle(fontSize: 14, color: textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDebtsList(BuildContext context, bool isDarkMode, Color cardColor,
      Color textPrimary, Color textSecondary, Color textMuted,
      List<BoxShadow> cardShadow) {
    return Column(
      children: _debts.map((debt) {
        final currentBalance = debt['current_balance'] ?? 0.0;
        final originalAmount = debt['original_amount'] ?? 1.0;
        final progress = 1 - (currentBalance / originalAmount);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: cardShadow,
          ),
          child: Dismissible(
            key: Key(debt['id']),
            direction: DismissDirection.endToStart,
            background: Container(
              decoration: BoxDecoration(
                color: SFMSTheme.dangerColor,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
            ),
            onDismissed: (direction) => _deleteDebt(debt['id']),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedDebtId = debt['id'];
                  _showPaymentModal = true;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getDebtStatusColor(context, currentBalance, originalAmount)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              _getDebtTypeEmoji(debt['debt_type']),
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
                                debt['debt_name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${debt['creditor_name']} • ${debt['interest_rate'] ?? 0}% APR',
                                style: TextStyle(fontSize: 12, color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'RM ${currentBalance.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getDebtStatusColor(context, currentBalance, originalAmount),
                              ),
                            ),
                            Text(
                              'of RM ${originalAmount.toStringAsFixed(0)}',
                              style: TextStyle(fontSize: 11, color: textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress Bar
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getDebtStatusColor(context, currentBalance, originalAmount),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}% Paid',
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                        Text(
                          'Min: RM ${(debt['minimum_payment'] ?? 0.0).toStringAsFixed(2)}/mo',
                          style: TextStyle(fontSize: 12, color: textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddDebtModal(BuildContext context, bool isDarkMode, Color cardColor,
      Color textPrimary, Color textSecondary, Color textMuted) {
    return Container(
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
                    Text('Add New Debt',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary)),
                    IconButton(
                      onPressed: () => setState(() => _showAddDebtModal = false),
                      icon: Icon(Icons.close, color: textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Form fields
                _buildFormField('Debt Name *', _debtNameController, 'e.g., Credit Card CIMB',
                    isDarkMode, textPrimary, textSecondary, textMuted),
                const SizedBox(height: 16),

                _buildFormField('Creditor Name *', _creditorNameController, 'e.g., CIMB Bank',
                    isDarkMode, textPrimary, textSecondary, textMuted),
                const SizedBox(height: 16),

                _buildFormField('Total Amount (RM) *', _debtAmountController, '0.00',
                    isDarkMode, textPrimary, textSecondary, textMuted,
                    isNumber: true),
                const SizedBox(height: 16),

                _buildDebtTypeDropdown(isDarkMode, cardColor, textPrimary, textSecondary, textMuted),
                const SizedBox(height: 16),

                _buildFormField('Interest Rate (%)', _interestRateController, 'e.g., 18',
                    isDarkMode, textPrimary, textSecondary, textMuted,
                    isNumber: true),
                const SizedBox(height: 16),

                _buildFormField('Minimum Payment (RM)', _minimumPaymentController, '0.00',
                    isDarkMode, textPrimary, textSecondary, textMuted,
                    isNumber: true),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => _showAddDebtModal = false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade300,
                          foregroundColor: textPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addDebt,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SFMSTheme.dangerColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Add Debt'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, String hint,
      bool isDarkMode, Color textPrimary, Color textSecondary, Color textMuted,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: TextStyle(color: textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textSecondary),
        hintText: hint,
        hintStyle: TextStyle(color: textMuted),
        filled: true,
        fillColor: isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDebtTypeDropdown(bool isDarkMode, Color cardColor, Color textPrimary,
      Color textSecondary, Color textMuted) {
    return DropdownButtonFormField<String>(
      value: _selectedDebtType,
      style: TextStyle(color: textPrimary),
      dropdownColor: cardColor,
      decoration: InputDecoration(
        labelText: 'Debt Type *',
        labelStyle: TextStyle(color: textSecondary),
        filled: true,
        fillColor: isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: _debtTypes.map((type) {
        return DropdownMenuItem(
          value: type['value'],
          child: Row(
            children: [
              Text(type['icon'], style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(type['label']),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedDebtType = value!),
    );
  }

  Widget _buildPaymentModal(BuildContext context, bool isDarkMode, Color cardColor,
      Color textPrimary, Color textSecondary, Color textMuted) {
    final selectedDebt = _debts.firstWhere((debt) => debt['id'] == _selectedDebtId);
    final double currentBalance = selectedDebt['current_balance'] ?? 0.0;
    final double minimumPayment = selectedDebt['minimum_payment'] ?? 0.0;

    return Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(_getDebtTypeEmoji(selectedDebt['debt_type']),
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Make Payment',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary)),
                        Text(selectedDebt['debt_name'],
                            style: TextStyle(fontSize: 14, color: textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _showPaymentModal = false),
                    icon: Icon(Icons.close, color: textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Current Balance Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Current Balance:', style: TextStyle(fontSize: 14, color: textSecondary)),
                    Text('RM ${currentBalance.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Payment Amount Field
              TextFormField(
                controller: _paymentAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  labelText: 'Payment Amount (RM)',
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
              const SizedBox(height: 16),

              // Quick Payment Options
              Wrap(
                spacing: 8,
                children: [
                  minimumPayment,
                  currentBalance / 4,
                  currentBalance / 2,
                  currentBalance,
                ].map((quickAmount) {
                  final label = quickAmount == minimumPayment
                      ? 'Min. Payment'
                      : quickAmount == currentBalance
                      ? 'Pay Off'
                      : 'RM ${quickAmount.toStringAsFixed(0)}';

                  return GestureDetector(
                    onTap: () => _paymentAmountController.text = quickAmount.toStringAsFixed(2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? SFMSTheme.accentTeal.withOpacity(0.2)
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode
                              ? SFMSTheme.accentTeal.withOpacity(0.3)
                              : Colors.blue.shade300,
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? SFMSTheme.accentTeal : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _showPaymentModal = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade300,
                        foregroundColor: textPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(_paymentAmountController.text);
                        if (amount != null && amount > 0) {
                          _makePayment(_selectedDebtId!, amount);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SFMSTheme.successColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Make Payment'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}