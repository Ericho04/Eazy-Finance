import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../providers/app_provider.dart';
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

  final List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'Food & Dining', 'emoji': '🍽️'},
    {'name': 'Transportation', 'emoji': '🚗'},
    {'name': 'Shopping', 'emoji': '🛍️'},
    {'name': 'Entertainment', 'emoji': '🎮'},
    {'name': 'Bills & Utilities', 'emoji': '🏠'},
    {'name': 'Healthcare', 'emoji': '❤️'},
    {'name': 'Coffee & Tea', 'emoji': '☕'},
    {'name': 'Fuel', 'emoji': '⛽'},
    {'name': 'Education', 'emoji': '📚'},
    {'name': 'Travel', 'emoji': '✈️'},
    {'name': 'Fitness', 'emoji': '💪'},
    {'name': 'Groceries', 'emoji': '🛒'},
    {'name': 'Others', 'emoji': '📝'},
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {'name': 'Salary', 'emoji': '💼'},
    {'name': 'Freelance', 'emoji': '💻'},
    {'name': 'Business', 'emoji': '🏢'},
    {'name': 'Investment', 'emoji': '📈'},
    {'name': 'Rental', 'emoji': '🏠'},
    {'name': 'Gift', 'emoji': '🎁'},
    {'name': 'Bonus', 'emoji': '💰'},
    {'name': 'Others', 'emoji': '📝'},
  ];

  @override
  void initState() {
    super.initState();
    _transactionType = widget.transactionType;
    _selectedCategory = widget.preSelectedCategory ?? '';

    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Apply prefilled data
    if (widget.prefilledData != null) {
      _amountController.text = widget.prefilledData!['amount'] ?? '';
      _descriptionController.text = widget.prefilledData!['description'] ?? '';
      _selectedCategory = widget.prefilledData!['category'] ?? _selectedCategory;

      if (widget.prefilledData!['date'] != null) {
        _selectedDate = DateTime.parse(widget.prefilledData!['date']);
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _successController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _currentCategories {
    return _transactionType == TransactionType.expense
        ? _expenseCategories
        : _incomeCategories;
  }

  void _handleQuickAmount(double amount) {
    _amountController.text = amount.toString();
  }

  void _clearForm() {
    _amountController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCategory = widget.preSelectedCategory ?? '';
      _selectedDate = DateTime.now();
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedCategory.isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    _buttonController.forward();

    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      final appProvider = Provider.of<AppProvider>(context, listen: false);

      // FIX 1: Added 'source' parameter (TransactionSource.manual)
      // FIX 2: Changed 'date' to use String format instead of DateTime
      await appProvider.addTransaction(Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'demo-user',
        type: _transactionType,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        description: _descriptionController.text,
        date: _selectedDate.toIso8601String().split('T')[0], // String format: "2024-10-30"
        source: TransactionSource.manual, // ✅ FIXED: Added required parameter
        // Note: createdAt is optional in Transaction constructor, defaults to DateTime.now()
      ));

      setState(() {
        _showSuccess = true;
      });

      _successController.forward();

      // Auto hide success and go back
      await Future.delayed(const Duration(seconds: 2));
      widget.onBack();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding transaction: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
      _buttonController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) {
      return _buildSuccessView();
    }

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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Back'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Icon(
                          _transactionType == TransactionType.expense
                              ? Icons.trending_down
                              : Icons.trending_up,
                          color: _transactionType == TransactionType.expense
                              ? Colors.red
                              : Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add ${_transactionType == TransactionType.expense ? 'Expense' : 'Income'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 80), // Balance header
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main form card
                        Container(
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
                              // Form header
                              Row(
                                children: [
                                  Text(
                                    _transactionType == TransactionType.expense ? '💸' : '💰',
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _transactionType == TransactionType.expense
                                            ? 'New Expense'
                                            : 'New Income',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                      const Text(
                                        'Fill in the details below',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Transaction type toggle
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() {
                                          _transactionType = TransactionType.expense;
                                        }),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            gradient: _transactionType == TransactionType.expense
                                                ? LinearGradient(
                                              colors: [
                                                Colors.red.shade400,
                                                Colors.pink.shade500,
                                              ],
                                            )
                                                : null,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.trending_down,
                                                size: 16,
                                                color: _transactionType == TransactionType.expense
                                                    ? Colors.white
                                                    : Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Expense',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: _transactionType == TransactionType.expense
                                                      ? Colors.white
                                                      : Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() {
                                          _transactionType = TransactionType.income;
                                        }),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            gradient: _transactionType == TransactionType.income
                                                ? LinearGradient(
                                              colors: [
                                                Colors.green.shade400,
                                                Colors.teal.shade500,
                                              ],
                                            )
                                                : null,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.trending_up,
                                                size: 16,
                                                color: _transactionType == TransactionType.income
                                                    ? Colors.white
                                                    : Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Income',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: _transactionType == TransactionType.income
                                                      ? Colors.white
                                                      : Colors.grey.shade600,
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
                              const SizedBox(height: 24),

                              // Amount field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.calculate, size: 16, color: Color(0xFF6B7280)),
                                      SizedBox(width: 8),
                                      Text(
                                        'Amount (RM)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF374151),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _amountController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      hintText: '0.00',
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: SFMSTheme.cartoonPurple, width: 2),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter an amount';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Please enter a valid amount';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  // Quick amount buttons
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [5, 10, 20, 50, 100, 200, 500, 1000].map((amount) {
                                      return GestureDetector(
                                        onTap: () => _handleQuickAmount(amount.toDouble()),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey.shade300),
                                          ),
                                          child: Text(
                                            'RM$amount',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Category selection
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.category, size: 16, color: Color(0xFF6B7280)),
                                      SizedBox(width: 8),
                                      Text(
                                        'Category',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF374151),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 1.2,
                                    ),
                                    itemCount: _currentCategories.length,
                                    itemBuilder: (context, index) {
                                      final category = _currentCategories[index];
                                      final isSelected = _selectedCategory == category['name'];

                                      return GestureDetector(
                                        onTap: () => setState(() {
                                          _selectedCategory = category['name'];
                                        }),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: isSelected
                                                ? LinearGradient(
                                              colors: _transactionType == TransactionType.expense
                                                  ? [Colors.red.shade400, Colors.pink.shade500]
                                                  : [Colors.green.shade400, Colors.teal.shade500],
                                            )
                                                : null,
                                            color: isSelected ? null : Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.transparent
                                                  : Colors.grey.shade300,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                category['emoji'],
                                                style: const TextStyle(fontSize: 20),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                category['name'],
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : const Color(0xFF374151),
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Description field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.description, size: 16, color: Color(0xFF6B7280)),
                                      SizedBox(width: 8),
                                      Text(
                                        'Description',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF374151),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _descriptionController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter ${_transactionType == TransactionType.expense ? 'expense' : 'income'} description...',
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: SFMSTheme.cartoonPurple, width: 2),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a description';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Date picker
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 16, color: Color(0xFF6B7280)),
                                      SizedBox(width: 8),
                                      Text(
                                        'Date',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF374151),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: _selectedDate,
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime.now().add(const Duration(days: 365)),
                                      );
                                      if (date != null) {
                                        setState(() {
                                          _selectedDate = date;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                                          const SizedBox(width: 12),
                                          Text(
                                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                          const Spacer(),
                                          Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Clear form button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _clearForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.clear, size: 16),
                                SizedBox(width: 8),
                                Text('Clear Form'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: AnimatedBuilder(
                            animation: _buttonController,
                            builder: (context, child) {
                              return ElevatedButton.icon(
                                onPressed: _isSubmitting ? null : _submitForm,
                                icon: _isSubmitting
                                    ? Transform.rotate(
                                  angle: _buttonController.value * 2 * math.pi,
                                  child: const Icon(Icons.refresh, size: 20),
                                )
                                    : const Icon(Icons.save, size: 20),
                                label: Text(
                                  _isSubmitting
                                      ? 'Saving...'
                                      : 'Save ${_transactionType == TransactionType.expense ? 'Expense' : 'Income'}',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _transactionType == TransactionType.expense
                                      ? Colors.red.shade400
                                      : Colors.green.shade400,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  disabledBackgroundColor: Colors.grey.shade300,
                                  disabledForegroundColor: Colors.grey.shade600,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFECFDF5),
              Color(0xFFF0FDF4),
              Color(0xFFDBEAFE),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _successController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + 0.2 * _successController.value,
                  child: Opacity(
                    opacity: _successController.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade400,
                                Colors.teal.shade400,
                              ],
                            ),
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
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'RM ${_amountController.text} ${_transactionType == TransactionType.expense ? 'expense' : 'income'} recorded successfully',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
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
