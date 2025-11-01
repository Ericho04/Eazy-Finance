import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../utils/theme.dart';

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

  bool _showAddDebtModal = false;
  bool _showPaymentModal = false;
  String? _selectedDebtId;

  final _debtNameController = TextEditingController();
  final _debtAmountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _paymentAmountController = TextEditingController();

  String _selectedDebtType = 'Credit Card';

  final List<String> _debtTypes = [
    'Credit Card',
    'Personal Loan',
    'Car Loan',
    'Student Loan',
    'Mortgage',
    'Business Loan',
    'Other',
  ];

  // Mock debts data - in real app this would come from your data source
  List<Map<String, dynamic>> _debts = [
    {
      'id': '1',
      'name': 'Credit Card - CIMB',
      'type': 'Credit Card',
      'totalAmount': 15000.0,
      'currentBalance': 8500.0,
      'interestRate': 18.0,
      'minimumPayment': 400.0,
      'dueDate': '2024-02-15',
      'color': 0xFFFF6B9D,
      'emoji': '💳',
    },
    {
      'id': '2',
      'name': 'Car Loan - Honda Civic',
      'type': 'Car Loan',
      'totalAmount': 85000.0,
      'currentBalance': 42000.0,
      'interestRate': 3.5,
      'minimumPayment': 1200.0,
      'dueDate': '2024-02-10',
      'color': 0xFF4E8EF7,
      'emoji': '🚗',
    },
    {
      'id': '3',
      'name': 'Personal Loan - Bank Islam',
      'type': 'Personal Loan',
      'totalAmount': 25000.0,
      'currentBalance': 12500.0,
      'interestRate': 8.5,
      'minimumPayment': 650.0,
      'dueDate': '2024-02-20',
      'color': 0xFF845EC2,
      'emoji': '🏦',
    },
  ];

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _paymentController.dispose();
    _debtNameController.dispose();
    _debtAmountController.dispose();
    _interestRateController.dispose();
    _paymentAmountController.dispose();
    super.dispose();
  }

  double get _totalDebt {
    return _debts.fold(0.0, (sum, debt) => sum + (debt['currentBalance'] as double));
  }

  double get _totalMinPayment {
    return _debts.fold(0.0, (sum, debt) => sum + (debt['minimumPayment'] as double));
  }

  String _getDebtTypeEmoji(String type) {
    switch (type) {
      case 'Credit Card':
        return '💳';
      case 'Car Loan':
        return '🚗';
      case 'Personal Loan':
        return '🏦';
      case 'Student Loan':
        return '🎓';
      case 'Mortgage':
        return '🏠';
      case 'Business Loan':
        return '🏢';
      default:
        return '💰';
    }
  }

  Color _getDebtStatusColor(double currentBalance, double totalAmount) {
    final percentage = currentBalance / totalAmount;
    if (percentage > 0.7) return Colors.red;
    if (percentage > 0.4) return Colors.orange;
    return Colors.green;
  }

  void _addDebt() {
    if (_debtNameController.text.isEmpty || _debtAmountController.text.isEmpty) {
      return;
    }

    final newDebt = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': _debtNameController.text,
      'type': _selectedDebtType,
      'totalAmount': double.parse(_debtAmountController.text),
      'currentBalance': double.parse(_debtAmountController.text),
      'interestRate': double.tryParse(_interestRateController.text) ?? 0.0,
      'minimumPayment': double.parse(_debtAmountController.text) * 0.03, // 3% of balance
      'dueDate': DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0],
      'color': [0xFFFF6B9D, 0xFF4E8EF7, 0xFF845EC2, 0xFF00D2FF][math.Random().nextInt(4)],
      'emoji': _getDebtTypeEmoji(_selectedDebtType),
    };

    setState(() {
      _debts.add(newDebt);
      _showAddDebtModal = false;
    });

    _debtNameController.clear();
    _debtAmountController.clear();
    _interestRateController.clear();
  }

  void _makePayment(String debtId, double amount) {
    setState(() {
      final debtIndex = _debts.indexWhere((debt) => debt['id'] == debtId);
      if (debtIndex != -1) {
        _debts[debtIndex]['currentBalance'] =
            math.max(0.0, (_debts[debtIndex]['currentBalance'] as double) - amount);

        if (_debts[debtIndex]['currentBalance'] == 0) {
          // Debt paid off celebration could be added here
        }
      }
      _showPaymentModal = false;
    });

    _paymentAmountController.clear();
    _paymentController.forward().then((_) => _paymentController.reset());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Container(
            decoration: const BoxDecoration(
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
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // Debt Overview Cards
                          _buildOverviewCards(),
                          const SizedBox(height: 24),

                          // Debt List Header
                          _buildDebtListHeader(),
                          const SizedBox(height: 16),

                          // Debt List
                          _buildDebtList(),
                          const SizedBox(height: 100), // Space for FAB
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Modals
          if (_showAddDebtModal) _buildAddDebtModal(),
          if (_showPaymentModal) _buildPaymentModal(),
        ],
      ),

      // Floating Action Button
      floatingActionButton: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _animationController.value,
            child: FloatingActionButton.extended(
              onPressed: () => setState(() => _showAddDebtModal = true),
              backgroundColor: SFMSTheme.cartoonPurple,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Debt'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Back'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.9),
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      '📊',
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Debt Management',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Track and manage your debts',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Column(
      children: [
        // Total Debt Card
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - _animationController.value)),
              child: Opacity(
                opacity: _animationController.value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade400,
                        Colors.orange.shade500,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.trending_down,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Debt',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'RM ${_totalDebt.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.warning,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Minimum Payment Card
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - _animationController.value)),
              child: Opacity(
                opacity: _animationController.value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        SFMSTheme.cartoonBlue,
                        SFMSTheme.cartoonCyan,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: SFMSTheme.cartoonBlue.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.payment,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Monthly Minimum',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'RM ${_totalMinPayment.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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
      ],
    );
  }

  Widget _buildDebtListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Your Debts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        Text(
          '${_debts.length} total',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildDebtList() {
    if (_debts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: const [
            Text(
              '🎉',
              style: TextStyle(fontSize: 48),
            ),
            SizedBox(height: 16),
            Text(
              'No debts!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You\'re debt-free! Keep up the great work.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: _debts.asMap().entries.map((entry) {
        final index = entry.key;
        final debt = entry.value;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                50 * (1 - _animationController.value),
                0,
              ),
              child: Opacity(
                opacity: _animationController.value,
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: index < _debts.length - 1 ? 16 : 0,
                  ),
                  child: _buildDebtCard(debt),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildDebtCard(Map<String, dynamic> debt) {
    final double totalAmount = debt['totalAmount'] as double;
    final double currentBalance = debt['currentBalance'] as double;
    final progressPercentage = 1 - (currentBalance / totalAmount);
    final statusColor = _getDebtStatusColor(currentBalance, totalAmount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
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
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(debt['color'] as int).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    debt['emoji'] as String,
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
                      debt['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(debt['color'] as int).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            debt['type'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(debt['color'] as int),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${debt['interestRate']}% APR',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDebtId = debt['id'] as String;
                    _showPaymentModal = true;
                  });
                },
                icon: const Icon(Icons.payment),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green.shade100,
                  foregroundColor: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Amounts
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Balance',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'RM ${currentBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Min. Payment',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'RM ${(debt['minimumPayment'] as double).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    '${(progressPercentage * 100).toStringAsFixed(1)}% paid',
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progressPercentage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Due Date
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                'Due: ${DateTime.parse(debt['dueDate'] as String).toString().split(' ')[0]}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddDebtModal() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
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
              // Header
              Row(
                children: [
                  const Text(
                    '💳',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Add New Debt',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _showAddDebtModal = false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Debt Name
              TextFormField(
                controller: _debtNameController,
                decoration: InputDecoration(
                  labelText: 'Debt Name',
                  hintText: 'e.g., Credit Card - CIMB',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Debt Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedDebtType,
                onChanged: (value) => setState(() => _selectedDebtType = value!),
                decoration: InputDecoration(
                  labelText: 'Debt Type',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _debtTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Text(_getDebtTypeEmoji(type)),
                        const SizedBox(width: 8),
                        Text(type),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _debtAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (RM)',
                  hintText: '0.00',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Interest Rate
              TextFormField(
                controller: _interestRateController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Interest Rate (%)',
                  hintText: '0.0',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _showAddDebtModal = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
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
                      onPressed: _addDebt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SFMSTheme.cartoonPurple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
    );
  }

  Widget _buildPaymentModal() {
    final selectedDebt = _debts.firstWhere((debt) => debt['id'] == _selectedDebtId);
    final double currentBalance = selectedDebt['currentBalance'] as double;
    final double minimumPayment = selectedDebt['minimumPayment'] as double;

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
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
              // Header
              Row(
                children: [
                  Text(
                    selectedDebt['emoji'] as String,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Make Payment',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          selectedDebt['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _showPaymentModal = false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Current Balance
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Current Balance:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      'RM ${currentBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Payment Amount
              TextFormField(
                controller: _paymentAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Payment Amount (RM)',
                  hintText: '0.00',
                  filled: true,
                  fillColor: Colors.grey.shade50,
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
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
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
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
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
                      onPressed: () {
                        final amount = double.tryParse(_paymentAmountController.text);
                        if (amount != null && amount > 0) {
                          _makePayment(_selectedDebtId!, amount);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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