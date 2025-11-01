import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../utils/theme.dart';

class FinancialTaxScreen extends StatefulWidget {
  final VoidCallback onBack;

  const FinancialTaxScreen({
    Key? key,
    required this.onBack,
  }) : super(key: key);

  @override
  State<FinancialTaxScreen> createState() => _FinancialTaxScreenState();
}

class _FinancialTaxScreenState extends State<FinancialTaxScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _calculatorController;

  String _selectedTaxYear = '2024';
  double _annualIncome = 0.0;
  double _epfContribution = 0.0;
  double _lifeInsurance = 0.0;
  double _educationFees = 0.0;
  double _medicalExpenses = 0.0;

  final _incomeController = TextEditingController();
  final _epfController = TextEditingController();
  final _insuranceController = TextEditingController();
  final _educationController = TextEditingController();
  final _medicalController = TextEditingController();

  bool _showCalculator = false;
  bool _showDeductions = false;

  // Malaysia Tax Brackets for 2024
  final List<Map<String, dynamic>> _taxBrackets = [
    {'min': 0.0, 'max': 5000.0, 'rate': 0.0, 'amount': 0.0},
    {'min': 5001.0, 'max': 20000.0, 'rate': 0.01, 'amount': 0.0},
    {'min': 20001.0, 'max': 35000.0, 'rate': 0.03, 'amount': 150.0},
    {'min': 35001.0, 'max': 50000.0, 'rate': 0.08, 'amount': 600.0},
    {'min': 50001.0, 'max': 70000.0, 'rate': 0.13, 'amount': 1800.0},
    {'min': 70001.0, 'max': 100000.0, 'rate': 0.21, 'amount': 4400.0},
    {'min': 100001.0, 'max': 250000.0, 'rate': 0.24, 'amount': 10700.0},
    {'min': 250001.0, 'max': 400000.0, 'rate': 0.245, 'amount': 46700.0},
    {'min': 400001.0, 'max': 600000.0, 'rate': 0.25, 'amount': 83450.0},
    {'min': 600001.0, 'max': 1000000.0, 'rate': 0.26, 'amount': 133450.0},
    {'min': 1000001.0, 'max': double.infinity, 'rate': 0.28, 'amount': 237450.0},
  ];

  // Common Tax Deductions in Malaysia
  final List<Map<String, dynamic>> _deductionCategories = [
    {
      'title': 'EPF Contribution',
      'icon': '🏦',
      'maxAmount': 4000.0,
      'description': 'Employee Provident Fund contributions',
      'color': 0xFF4CAF50,
    },
    {
      'title': 'Life Insurance',
      'icon': '🛡️',
      'maxAmount': 3000.0,
      'description': 'Life insurance premiums',
      'color': 0xFF2196F3,
    },
    {
      'title': 'Education Fees',
      'icon': '🎓',
      'maxAmount': 7000.0,
      'description': 'Education fees for self',
      'color': 0xFF9C27B0,
    },
    {
      'title': 'Medical Expenses',
      'icon': '🏥',
      'maxAmount': 8000.0,
      'description': 'Medical expenses for self, spouse, children',
      'color': 0xFFFF5722,
    },
    {
      'title': 'Parent Medical',
      'icon': '👴',
      'maxAmount': 8000.0,
      'description': 'Medical expenses for parents',
      'color': 0xFFFF9800,
    },
    {
      'title': 'Disabled Individual',
      'icon': '♿',
      'maxAmount': 6000.0,
      'description': 'Expenses for disabled individual',
      'color': 0xFF607D8B,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _calculatorController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calculatorController.dispose();
    _incomeController.dispose();
    _epfController.dispose();
    _insuranceController.dispose();
    _educationController.dispose();
    _medicalController.dispose();
    super.dispose();
  }

  Map<String, double> _calculateTax() {
    final totalDeductions = _epfContribution + _lifeInsurance + _educationFees + _medicalExpenses;
    final taxableIncome = math.max(0.0, _annualIncome - totalDeductions);

    double tax = 0.0;
    double remainingIncome = taxableIncome;

    for (final bracket in _taxBrackets) {
      if (remainingIncome <= 0) break;

      final double minAmount = (bracket['min'] as num).toDouble();
      final double maxAmount = bracket['max'] == double.infinity
          ? double.infinity
          : (bracket['max'] as num).toDouble();
      final double rate = (bracket['rate'] as num).toDouble();
      final double baseAmount = (bracket['amount'] as num).toDouble();

      if (taxableIncome > minAmount) {
        final taxableAtThisBracket = math.min(remainingIncome, maxAmount - minAmount);
        tax = baseAmount + (taxableAtThisBracket * rate);
        break; // Use the bracket amount directly
      }
    }

    final effectiveRate = taxableIncome > 0 ? (tax / taxableIncome) * 100 : 0.0;
    final takeHome = _annualIncome - tax;

    return {
      'grossIncome': _annualIncome,
      'totalDeductions': totalDeductions,
      'taxableIncome': taxableIncome,
      'totalTax': tax,
      'effectiveRate': effectiveRate,
      'takeHome': takeHome,
    };
  }

  void _updateCalculation() {
    setState(() {
      _annualIncome = double.tryParse(_incomeController.text) ?? 0.0;
      _epfContribution = double.tryParse(_epfController.text) ?? 0.0;
      _lifeInsurance = double.tryParse(_insuranceController.text) ?? 0.0;
      _educationFees = double.tryParse(_educationController.text) ?? 0.0;
      _medicalExpenses = double.tryParse(_medicalController.text) ?? 0.0;
    });

    _calculatorController.forward().then((_) => _calculatorController.reset());
  }

  @override
  Widget build(BuildContext context) {
    final taxCalculation = _calculateTax();

    return Scaffold(
      body: Container(
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
                      // Tax Year Selection
                      _buildTaxYearSelection(),
                      const SizedBox(height: 24),

                      // Tax Summary Cards
                      _buildTaxSummaryCards(taxCalculation),
                      const SizedBox(height: 24),

                      // Quick Actions
                      _buildQuickActions(),
                      const SizedBox(height: 24),

                      // Tax Calculator
                      if (_showCalculator) ...[
                        _buildTaxCalculator(),
                        const SizedBox(height: 24),
                      ],

                      // Tax Deductions Guide
                      if (_showDeductions) ...[
                        _buildDeductionsGuide(),
                        const SizedBox(height: 24),
                      ],

                      // Tax Tips
                      _buildTaxTips(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
              children: const [
                Row(
                  children: [
                    Text(
                      '📊',
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Tax Planning',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Plan and calculate your taxes',
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

  Widget _buildTaxYearSelection() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _animationController.value)),
          child: Opacity(
            opacity: _animationController.value,
            child: Container(
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
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          SFMSTheme.cartoonBlue,
                          SFMSTheme.cartoonCyan,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
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
                          'Tax Year',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        DropdownButton<String>(
                          value: _selectedTaxYear,
                          onChanged: (value) => setState(() => _selectedTaxYear = value!),
                          underline: const SizedBox(),
                          items: ['2024', '2023', '2022'].map((year) {
                            return DropdownMenuItem(
                              value: year,
                              child: Text(
                                year,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            );
                          }).toList(),
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
    );
  }

  Widget _buildTaxSummaryCards(Map<String, double> calculation) {
    final cards = [
      {
        'title': 'Estimated Tax',
        'value': 'RM ${calculation['totalTax']!.toStringAsFixed(2)}',
        'icon': Icons.receipt_long,
        'color': Colors.red.shade400,
        'subtitle': '${calculation['effectiveRate']!.toStringAsFixed(1)}% effective rate',
      },
      {
        'title': 'Take Home',
        'value': 'RM ${calculation['takeHome']!.toStringAsFixed(2)}',
        'icon': Icons.account_balance_wallet,
        'color': Colors.green.shade400,
        'subtitle': 'After tax income',
      },
      {
        'title': 'Total Deductions',
        'value': 'RM ${calculation['totalDeductions']!.toStringAsFixed(2)}',
        'icon': Icons.savings,
        'color': SFMSTheme.cartoonPurple,
        'subtitle': 'Tax savings',
      },
    ];

    return Column(
      children: cards.asMap().entries.map((entry) {
        final index = entry.key;
        final card = entry.value;

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
                    bottom: index < cards.length - 1 ? 16 : 0,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        card['color'] as Color,
                        (card['color'] as Color).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: (card['color'] as Color).withOpacity(0.3),
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
                        child: Icon(
                          card['icon'] as IconData,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              card['value'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              card['subtitle'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
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
        );
      }).toList(),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _showCalculator = !_showCalculator),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SFMSTheme.cartoonBlue,
                    SFMSTheme.cartoonCyan,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: SFMSTheme.cartoonBlue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.calculate,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tax Calculator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _showDeductions = !_showDeductions),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SFMSTheme.cartoonPurple,
                    SFMSTheme.cartoonPink,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: SFMSTheme.cartoonPurple.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.receipt,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Deductions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaxCalculator() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          const Row(
            children: [
              Text(
                '🧮',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: 12),
              Text(
                'Tax Calculator',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Annual Income
          TextFormField(
            controller: _incomeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Annual Income (RM)',
              hintText: '0.00',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.attach_money),
            ),
            onChanged: (_) => _updateCalculation(),
          ),
          const SizedBox(height: 16),

          // EPF Contribution
          TextFormField(
            controller: _epfController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'EPF Contribution (RM)',
              hintText: '0.00',
              helperText: 'Max: RM 4,000',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.savings),
            ),
            onChanged: (_) => _updateCalculation(),
          ),
          const SizedBox(height: 16),

          // Life Insurance
          TextFormField(
            controller: _insuranceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Life Insurance (RM)',
              hintText: '0.00',
              helperText: 'Max: RM 3,000',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.security),
            ),
            onChanged: (_) => _updateCalculation(),
          ),
          const SizedBox(height: 16),

          // Education Fees
          TextFormField(
            controller: _educationController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Education Fees (RM)',
              hintText: '0.00',
              helperText: 'Max: RM 7,000',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.school),
            ),
            onChanged: (_) => _updateCalculation(),
          ),
          const SizedBox(height: 16),

          // Medical Expenses
          TextFormField(
            controller: _medicalController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Medical Expenses (RM)',
              hintText: '0.00',
              helperText: 'Max: RM 8,000',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.local_hospital),
            ),
            onChanged: (_) => _updateCalculation(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionsGuide() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          const Row(
            children: [
              Text(
                '📋',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: 12),
              Text(
                'Tax Deductions Guide',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Column(
            children: _deductionCategories.map((deduction) {
              final double maxAmount = (deduction['maxAmount'] as num).toDouble();
              final int colorValue = deduction['color'] as int;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(colorValue).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          deduction['icon'] as String,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deduction['title'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            deduction['description'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      'RM ${maxAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(colorValue),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxTips() {
    final tips = [
      {
        'title': 'Keep Receipts',
        'description': 'Always keep receipts for medical expenses, education fees, and other deductible items.',
        'icon': '🧾',
        'color': Colors.blue,
      },
      {
        'title': 'Maximize EPF',
        'description': 'Contribute to EPF to reduce taxable income and secure your retirement.',
        'icon': '🏦',
        'color': Colors.green,
      },
      {
        'title': 'Plan Ahead',
        'description': 'Make tax-deductible contributions before the year ends to optimize savings.',
        'icon': '📅',
        'color': Colors.orange,
      },
      {
        'title': 'File Early',
        'description': 'Submit your tax return by March 31st to avoid penalties.',
        'icon': '⏰',
        'color': Colors.red,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
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
          const Row(
            children: [
              Text(
                '💡',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: 12),
              Text(
                'Tax Planning Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Column(
            children: tips.map((tip) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (tip['color'] as Color).withOpacity(0.1),
                      (tip['color'] as Color).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (tip['color'] as Color).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      tip['icon'] as String,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip['title'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tip['description'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}