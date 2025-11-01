
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../providers/app_provider.dart';
import '../utils/theme.dart';
import '../widget/ai_tip_card.dart';

class InsightsScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const InsightsScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;
  String _timeRange = 'month';


  String _aiTipText = "Generating your personal financial tip...";
  bool _isAiLoading = true;
  // ⚠️ 警告: 永远不要将您的 API 密钥硬编码在应用中！
  // 这是一个占位符。请从安全的地方（如环境变量）加载它。
  final String _apiKey = "YOUR_GOOGLE_AI_API_KEY_HERE";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _animationController.forward();
    _floatingController.repeat();

    // ✨ 5. (添加) 在屏幕加载时调用 AI
    _fetchAiTip();
  }

  // ✨ 6. (添加) 获取 AI 建议的函数
  Future<void> _fetchAiTip() async {
    // 阻止在演示模式下或没有 API 密钥时运行
    if (_apiKey == "YOUR_GOOGLE_AI_API_KEY_HERE") {
      setState(() {
        _aiTipText = "AI Tip is disabled. Please add an API key in insights_screen.dart to enable this feature.";
        _isAiLoading = false;
      });
      return;
    }

    setState(() {
      _isAiLoading = true;
    });

    try {
      final appProvider = context.read<AppProvider>();

      // 1. 准备数据
      // (注意: 仅发送摘要，不要发送所有交易以保护隐私)
      final monthlyExpenses = appProvider.getMonthlyExpenses();
      final categoryBreakdown = appProvider.getCategoryBreakdown();
      final recentTransactions = appProvider.getRecentTransactions(limit: 5);

      // 将数据转换为简单的 JSON 字符串
      final contextData = jsonEncode({
        'monthlyExpenses': monthlyExpenses,
        'categoryBreakdown': categoryBreakdown,
        'recentTransactionsPreview': recentTransactions.map((t) => {'category': t.category, 'amount': t.amount}).toList(),
      });

      // 2. 初始化模型
      final model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);

      // 3. 创建提示 (Prompt)
      final prompt = """
      You are a friendly Malaysian financial advisor. 
      Based on the following user financial data (in JSON format), provide one short, actionable financial tip (max 2-3 sentences). 
      Address the user directly (e.g., "You...").
      Data: $contextData
      """;

      // 4. 生成内容
      final response = await model.generateContent([Content.text(prompt)]);

      // 5. 更新 UI
      setState(() {
        _aiTipText = response.text ?? "Keep up the good work! Track your expenses daily.";
        _isAiLoading = false;
      });

    } catch (e) {
      print("AI Tip Error: $e");
      setState(() {
        _aiTipText = "Could not load AI tip. Check your connection or API key.";
        _isAiLoading = false;
      });
    }
  }


  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  // ... (您的 _buildChart, _getTopCategories, _getSpendingInsight, _getCategoryColor 函数保持不变)
  // ... (从您的 insights_screen.dart 文件粘贴它们到这里)

  // (从您的文件中粘贴 _buildChart)
  Widget _buildChart(AppProvider appProvider) {
    // ...
    return Container(); // 您的图表代码
  }

  // (从您的文件中粘贴 _getTopCategories)
  List<Map<String, dynamic>> _getTopCategories(AppProvider appProvider) {
    // ...
    return []; // 您的分类代码
  }

  // (从您的文件中粘贴 _getSpendingInsight)
  String _getSpendingInsight(double amount) {
    // ...
    return ""; // 您的洞察代码
  }

  // (从您的文件中粘贴 _getCategoryColor)
  Color _getCategoryColor(int index) {
    // ...
    return Colors.blue;
  }


  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final monthlyExpenses = appProvider.getMonthlyExpenses();
    final topCategories = _getTopCategories(appProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header
            const Text(
              'Financial Insights',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your smart financial summary and tips.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),


            AiTipCard(
              title: "AI Financial Tip",
              tip: _aiTipText, // 使用我们从 AI 获取的状态变量
              icon: _isAiLoading ? Icons.sync : Icons.auto_awesome, // 显示加载图标
              color: Colors.purple,
            ),

            const SizedBox(height: 24),


            const Text(
              'Financial Tools',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._financialTools.map((tool) {
              return Card();
            }).toList(),


            const SizedBox(height: 24),

            const Text(
              'Category Breakdown',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildChart(appProvider),
            ...topCategories.map((category) {
              return ListTile( );
            }).toList(),
          ],
        ),
      ),
    );
  }
}


final List<Map<String, dynamic>> _financialTools = [
  {
    'title': 'Debt Manager',
    'description': 'Track and manage your debts',
    'icon': Icons.credit_card,
    'colors': [SFMSTheme.dangerColor, const Color(0xFFFF8A65)],
    'route': 'financial-debts',
  },
  {
    'title': 'Accounts',
    'description': 'Manage your bank accounts',
    'icon': Icons.account_balance,
    'colors': [SFMSTheme.cartoonBlue, const Color(0xFF7BB3FF)],
    'route': 'financial-accounts',
  },
  {
    'title': 'Financial Goals',
    'description': 'Save for your future',
    'icon': Icons.track_changes,
    'colors': [SFMSTheme.successColor, const Color(0xFF81C784)],
    'route': 'financial-goals',
  },
  {
    'title': 'Tax Calculator',
    'description': 'Estimate your income tax',
    'icon': Icons.calculate,
    'colors': [SFMSTheme.warningColor, const Color(0xFFFFD54F)],
    'route': 'financial-tax',
  },
];