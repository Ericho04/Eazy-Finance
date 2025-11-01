import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  runApp(SFMSApp(prefs: prefs));
}

class SFMSApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  const SFMSApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => AppProvider(prefs),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: 'SFMS - Smart Finance Management',
            theme: SFMSTheme.lightTheme,
            darkTheme: SFMSTheme.darkTheme,
            themeMode: ThemeMode.system,
            debugShowCheckedModeBanner: false,
            home: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: animation.drive(
                    Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
                  ),
                  child: child,
                );
              },
              child: authProvider.isAuthenticated
                  ? const MainScreen()
                  : const LoginScreen(),
            ),
          );
        },
      ),
    );
  }
}