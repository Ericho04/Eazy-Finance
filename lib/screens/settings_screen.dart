import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {

  // 这是我们添加的第 1 行
  final Function(String) onNavigate;

  // 这是我们修改过的构造函数
  const SettingsScreen({
    Key? key,
    required this.onNavigate, // <-- 这是我们添加的第 2 行
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '⚙️',
                style: TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              const Text(
                'Settings Screen',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // 这里我们使用 Provider.of<AuthProvider>...
                  // 注意：'AuthProvider' 需要在您的 providers 文件夹中定义
                  try {
                    Provider.of<AuthProvider>(context, listen: false).signOut();
                  } catch (e) {
                    print('Error during logout: $e');
                    // 如果 AuthProvider 找不到，显示一个提示
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error logging out. AuthProvider not found?')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Logout'),
              ),
              TextButton(
                onPressed: () => onNavigate('dashboard'),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}