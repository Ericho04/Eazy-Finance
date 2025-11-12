import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../models/transaction.dart';
import '../utils/theme.dart';

class ExpenseEntryScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(String) onNavigate;
  final String? preSelectedCategory;
  final TransactionType transactionType;
  final Map<String, dynamic>? prefilledData;

  const ExpenseEntryScreen({
    Key? key,
    required this.onBack,
    required this.onNavigate,
    this.preSelectedCategory,
    this.transactionType = TransactionType.expense,
    this.prefilledData,
  }) : super(key: key);
// ...

  @override
  State<ExpenseEntryScreen> createState() => _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState extends State<ExpenseEntryScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  late AnimationController _successController;
  late AnimationController _buttonController;

  TransactionType _transactionType = TransactionType.expense;
  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  bool _showSuccess = false;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _transactionType = widget.transactionType;
    _selectedCategory =
        widget.preSelectedCategory ?? _getCategoryList().first['id'] as String;

    _successController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _successController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onBack();
      }
    });
  }

  @override
  void dispose() {
    _successController.dispose();
    _buttonController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }


  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = context.read<AuthProvider>().user?.id;
      if (userId == null) {
        throw Exception('用户未登录');
      }

      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text;



      // ✅ 修复：获取 category 的 name 而不是 id
      // 这样才能与 budget.category 匹配，触发器才能自动更新 budget.spent
      final categoryList = _getCategoryList();
      final selectedCategoryInfo = categoryList.firstWhere(
            (cat) => cat['id'] == _selectedCategory,
        orElse: () => categoryList.first,
      );
      final categoryName = selectedCategoryInfo['name'] as String;

      print('📝 Saving transaction:');
      print('   Category ID: $_selectedCategory');
      print('   Category Name: $categoryName');
      print('   Amount: RM $amount');

      await supabase.from('transactions').insert({
        'user_id': userId,
        'amount': amount,
        'description': description,
        'category': categoryName,  // ✅ 使用 name 而不是 id
        'type': _transactionType.name,
        'transaction_date': _selectedDate.toIso8601String(),
        'source': 'manual'
      });

      await context.read<AppProvider>().fetchTransactions();

      await context.read<AppProvider>().fetchBudgets();


      // 5. 显示成功动画
      setState(() {
        _showSuccess = true;
        _isSubmitting = false;
      });
      _successController.forward();

    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('提交失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> _getCategoryList() {
    return _transactionType == TransactionType.expense
        ? SFMSTheme.expenseCategories
        : SFMSTheme.incomeCategories;
  }

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _transactionType = type;
      _selectedCategory = _getCategoryList().first['id'] as String;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    // Dark Mode Support
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkMode
                ? ColorScheme.dark(
                    primary: _transactionType == TransactionType.expense
                        ? SFMSTheme.darkAccentCoral
                        : SFMSTheme.darkAccentEmerald,
                    onPrimary: Colors.white,
                    surface: SFMSTheme.darkCardBg,
                    onSurface: SFMSTheme.darkTextPrimary,
                  )
                : ColorScheme.light(
                    primary: _transactionType == TransactionType.expense
                        ? SFMSTheme.dangerColor
                        : SFMSTheme.successColor,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
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
    final cardColor = isDarkMode ? SFMSTheme.darkCardBg : SFMSTheme.cardColor;
    final cardShadow = isDarkMode ? SFMSTheme.darkCardShadow : SFMSTheme.softCardShadow;

    final primaryColor = _transactionType == TransactionType.expense
        ? (isDarkMode ? SFMSTheme.darkAccentCoral : SFMSTheme.dangerColor)
        : (isDarkMode ? SFMSTheme.darkAccentEmerald : SFMSTheme.successColor);
    final secondaryColor = _transactionType == TransactionType.expense
        ? (isDarkMode ? const Color(0xFF4A2626) : const Color(0xFFFFECEB))
        : (isDarkMode ? const Color(0xFF1F3A2E) : const Color(0xFFE6F7EB));

    return Material(
      color: Colors.transparent,
      child: Center(
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          offset: const Offset(0, 0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: _showSuccess
                ? _buildSuccessView(context, primaryColor, isDarkMode, cardColor, textPrimary, textMuted)
                : _buildFormView(context, primaryColor, secondaryColor, isDarkMode, cardColor, cardShadow, textPrimary, textSecondary, textMuted),
          ),
        ),
      ),
    );
  }

  //
  // --- 你的 UI 代码 (保持不变) ---
  //

  Widget _buildFormView(BuildContext context, Color primaryColor, Color secondaryColor, bool isDarkMode, Color cardColor, List<BoxShadow> cardShadow, Color textPrimary, Color textSecondary, Color textMuted) {
    return Container(
      key: const ValueKey('form'),
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: cardShadow,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _transactionType == TransactionType.expense
                        ? 'Add Expense'
                        : 'Add Income',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: _isSubmitting ? null : widget.onBack,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Type Toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTypeButton(
                        'Expense',
                        TransactionType.expense,
                        primaryColor,
                      ),
                    ),
                    Expanded(
                      child: _buildTypeButton(
                        'Income',
                        TransactionType.income,
                        primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount (RM)',
                  prefixIcon:
                  const Icon(Icons.attach_money_rounded, color: Color(0xFF6B7280)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: const Icon(Icons.description_rounded,
                      color: Color(0xFF6B7280)),
                  filled: true,
                  fillColor: isDarkMode ? SFMSTheme.darkBgSecondary : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category
              _buildCategorySelector(primaryColor, secondaryColor),
              const SizedBox(height: 24),

              // Date
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: const Icon(Icons.calendar_today_rounded,
                        color: Color(0xFF6B7280)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: primaryColor.withOpacity(0.4),
                  elevation: 10,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : const Text(
                  'Add Transaction',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(
      BuildContext context, String title, TransactionType type, Color primaryColor, bool isDarkMode, Color textSecondary) {
    final bool isSelected = _transactionType == type;
    return GestureDetector(
      onTap: () => _onTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context, Color primaryColor, Color secondaryColor, bool isDarkMode, Color cardColor, Color textPrimary, Color textSecondary) {
    final categories = _getCategoryList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: categories.map((category) {
            final bool isSelected = _selectedCategory == category['id'];
            return ChoiceChip(
              label: Text(category['name'] as String),
              avatar: Text(
                category['emoji'] as String,
                style: const TextStyle(fontSize: 16),
              ),
              labelPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category['id'] as String;
                });
              },
              backgroundColor: isDarkMode ? SFMSTheme.darkBgSecondary : Colors.white,
              selectedColor: primaryColor,
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : textPrimary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? primaryColor : (isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade300),
                ),
              ),
              pressElevation: 0,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSuccessView(BuildContext context, Color primaryColor, bool isDarkMode, Color cardColor, Color textPrimary, Color textMuted) {
    return Container(
      key: const ValueKey('success'),
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: ScaleTransition(
          scale: _successController.drive(CurveTween(curve: Curves.elasticOut)),
          child: FadeTransition(
            opacity: _successController,
            child: Builder(
              builder: (context) {
                // 确保 _amountController 仍然有值
                String amountText = _amountController.text;
                try {
                  amountText = double.parse(amountText).toStringAsFixed(2);
                } catch (e) {
                  amountText = '...'; // 回退
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor.withOpacity(0.8), primaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          '${_transactionType == TransactionType.expense ? 'Expense' : 'Income'} Added!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'RM $amountText ${_transactionType == TransactionType.expense ? 'expense' : 'income'} recorded successfully',
                          style: TextStyle(
                            fontSize: 16,
                            color: textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
