import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/theme.dart';
import '../providers/theme_provider.dart';

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
  final supabase = Supabase.instance.client;

  String _selectedTaxYear = '2024';
  double _annualIncome = 0.0;
  double _totalDeductions = 0.0;

  bool _isLoading = false;
  Map<String, dynamic>? _taxData;
  List<Map<String, dynamic>> _deductions = [];

  final _incomeController = TextEditingController();
  bool _showCalculator = false;

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
    _fetchTaxData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calculatorController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _fetchTaxData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // Fetch tax planning data
      final taxResponse = await supabase
          .from('tax_planning')
          .select()
          .eq('user_id', user.id)
          .eq('tax_year', _selectedTaxYear)
          .maybeSingle();

      if (taxResponse != null) {
        setState(() {
          _taxData = taxResponse;
          _annualIncome = taxResponse['annual_income'] ?? 0.0;
          _totalDeductions = taxResponse['total_deductions'] ?? 0.0;
          _incomeController.text = _annualIncome.toString();
        });

        // Fetch deductions
        final deductionsResponse = await supabase
            .from('tax_deductions')
            .select()
            .eq('tax_planning_id', taxResponse['id']);

        setState(() {
          _deductions = deductionsResponse as List<Map<String, dynamic>>;
        });
      }
    } catch (e) {
      print('Error fetching tax data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveTaxData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final taxCalculation = _calculateTax();

      // Insert or update tax_planning
      final response = await supabase
          .from('tax_planning')
          .upsert({
        'user_id': user.id,
        'tax_year': _selectedTaxYear,
        'annual_income': _annualIncome,
        'estimated_tax': taxCalculation['totalTax'],
        'total_deductions': _totalDeductions,
        'taxable_income': taxCalculation['taxableIncome'],
        'effective_rate': taxCalculation['effectiveRate'],
      })
          .select()
          .single();

      setState(() {
        _taxData = response;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tax data saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save tax data: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _addDeduction(String category, String description, double amount, double maxAmount) async {
    if (_taxData == null) {
      // First save the tax planning data
      await _saveTaxData();
      if (_taxData == null) return;
    }

    try {
      await supabase.from('tax_deductions').insert({
        'tax_planning_id': _taxData!['id'],
        'category': category,
        'description': description,
        'amount': amount,
        'max_amount': maxAmount,
        'is_claimable': true,
      });

      await _fetchTaxData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deduction added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add deduction: ${e.toString()}')),
        );
      }
    }
  }

  Map<String, double> _calculateTax() {
    final taxableIncome = math.max(0.0, _annualIncome - _totalDeductions);

    double tax = 0.0;

    for (final bracket in _taxBrackets) {
      final double minAmount = (bracket['min'] as num).toDouble();
      final double rate = (bracket['rate'] as num).toDouble();
      final double baseAmount = (bracket['amount'] as num).toDouble();

      if (taxableIncome > minAmount) {
        tax = baseAmount + ((taxableIncome - minAmount) * rate);
        if (bracket['max'] != double.infinity && taxableIncome <= (bracket['max'] as num).toDouble()) {
          break;
        }
      }
    }

    final effectiveRate = taxableIncome > 0 ? (tax / taxableIncome) * 100 : 0.0;
    final takeHome = _annualIncome - tax;

    return {
      'grossIncome': _annualIncome,
      'totalDeductions': _totalDeductions,
      'taxableIncome': taxableIncome,
      'totalTax': tax,
      'effectiveRate': effectiveRate,
      'takeHome': takeHome,
    };
  }

  void _updateCalculation() {
    setState(() {
      _annualIncome = double.tryParse(_incomeController.text) ?? 0.0;
      _totalDeductions = _deductions.fold(0.0, (sum, d) => sum + (d['amount'] ?? 0.0));
    });
    _calculatorController.forward().then((_) => _calculatorController.reset());
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

    final taxCalculation = _calculateTax();

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
          child: Column(
            children: [
              // Header
              _buildHeader(context, isDarkMode, cardColor, textPrimary, textSecondary),

              Expanded(
                child: _isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.primaryColor,
                  ),
                )
                    : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Tax Year Selection
                      _buildTaxYearSelection(context, isDarkMode, cardColor, textPrimary, textSecondary, cardShadow),
                      const SizedBox(height: 24),

                      // Tax Summary
                      _buildTaxSummary(context, isDarkMode, cardColor, textPrimary, textSecondary, cardShadow, taxCalculation),
                      const SizedBox(height: 24),

                      // Income Input
                      _buildIncomeInput(context, isDarkMode, cardColor, textPrimary, textSecondary, textMuted, cardShadow),
                      const SizedBox(height: 24),

                      // Deductions List
                      _buildDeductionsList(context, isDarkMode, cardColor, textPrimary, textSecondary, textMuted, cardShadow),
                      const SizedBox(height: 24),

                      // Quick Deduction Categories
                      _buildQuickDeductions(context, isDarkMode, cardColor, textPrimary, textSecondary, cardShadow),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveTaxData,
        backgroundColor: isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.primaryColor,
        child: const Icon(Icons.save, color: Colors.white),
        tooltip: 'Save Tax Data',
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode, Color cardColor, Color textPrimary, Color textSecondary) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tax Planning',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              Text(
                'Malaysia Tax Calculator',
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaxYearSelection(BuildContext context, bool isDarkMode, Color cardColor, Color textPrimary, Color textSecondary, List<BoxShadow> cardShadow) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tax Year',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [SFMSTheme.cartoonPurple, const Color(0xFFB39BC8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: _selectedTaxYear,
              underline: const SizedBox(),
              dropdownColor: cardColor,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              items: ['2023', '2024', '2025'].map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(year),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTaxYear = value!;
                });
                _fetchTaxData();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxSummary(BuildContext context, bool isDarkMode, Color cardColor, Color textPrimary, Color textSecondary, List<BoxShadow> cardShadow, Map<String, double> taxCalculation) {
    return AnimatedBuilder(
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
                    : [SFMSTheme.cartoonPurple, const Color(0xFFB39BC8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: cardShadow,
            ),
            child: Column(
              children: [
                const Text(
                  '📊',
                  style: TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Estimated Tax',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'RM ${taxCalculation['totalTax']!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Take Home',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'RM ${taxCalculation['takeHome']!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.white24,
                    ),
                    Column(
                      children: [
                        Text(
                          'Effective Rate',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${taxCalculation['effectiveRate']!.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIncomeInput(BuildContext context, bool isDarkMode, Color cardColor, Color textPrimary, Color textSecondary, Color textMuted, List<BoxShadow> cardShadow) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💼', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                'Annual Income',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _incomeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'Gross Annual Income (RM)',
              labelStyle: TextStyle(color: textSecondary),
              hintText: '0.00',
              hintStyle: TextStyle(color: textMuted),
              filled: true,
              fillColor: isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefix: Text('RM ', style: TextStyle(color: textPrimary)),
            ),
            onChanged: (_) => _updateCalculation(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionsList(BuildContext context, bool isDarkMode, Color cardColor, Color textPrimary, Color textSecondary, Color textMuted, List<BoxShadow> cardShadow) {
    if (_deductions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: cardShadow,
        ),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: textMuted),
            const SizedBox(height: 16),
            Text(
              'No deductions added yet',
              style: TextStyle(
                fontSize: 16,
                color: textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add deductions below to reduce your taxable income',
              style: TextStyle(fontSize: 14, color: textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tax Deductions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              Text(
                'Total: RM ${_totalDeductions.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: SFMSTheme.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._deductions.map((deduction) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deduction['category'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      if (deduction['description'] != null)
                        Text(
                          deduction['description'],
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                    ],
                  ),
                  Text(
                    'RM ${(deduction['amount'] ?? 0.0).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: SFMSTheme.successColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildQuickDeductions(BuildContext context, bool isDarkMode, Color cardColor, Color textPrimary, Color textSecondary, List<BoxShadow> cardShadow) {
    final quickDeductions = [
      {'category': 'EPF', 'icon': '🏦', 'max': 4000.0, 'desc': 'EPF Contribution'},
      {'category': 'Insurance', 'icon': '🛡️', 'max': 3000.0, 'desc': 'Life Insurance'},
      {'category': 'Medical', 'icon': '🏥', 'max': 8000.0, 'desc': 'Medical Expenses'},
      {'category': 'Education', 'icon': '🎓', 'max': 7000.0, 'desc': 'Education Fees'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Add Deductions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: quickDeductions.map((item) {
              return GestureDetector(
                onTap: () {
                  // Show dialog to add amount
                  showDialog(
                    context: context,
                    builder: (context) {
                      final amountController = TextEditingController();
                      return AlertDialog(
                        backgroundColor: cardColor,
                        title: Text('Add ${item['desc']}', style: TextStyle(color: textPrimary)),
                        content: TextFormField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Amount (Max: RM ${item['max']})',
                            labelStyle: TextStyle(color: textSecondary),
                            hintText: '0.00',
                            filled: true,
                            fillColor: isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel', style: TextStyle(color: textSecondary)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final amount = double.tryParse(amountController.text) ?? 0.0;
                              if (amount > 0) {
                                _addDeduction(
                                  item['category'] as String,
                                  item['desc'] as String,
                                  math.min(amount, item['max'] as double),
                                  item['max'] as double,
                                );
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SFMSTheme.successColor,
                            ),
                            child: const Text('Add', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        SFMSTheme.primaryColor.withOpacity(0.8),
                        SFMSTheme.primaryColor.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(item['icon'] as String, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['category'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Max: RM ${item['max']}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}