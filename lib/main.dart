import 'package:flutter/material.dart';
import 'package:app_kampus/auth/login_screen.dart';
import 'package:app_kampus/theme_notifier.dart'; // Import pusat tema global

void main() {
  runApp(const KampusPintarApp());
}

class KampusPintarApp extends StatelessWidget {
  const KampusPintarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, currentTheme, child) {
        
        final bool isDark = currentTheme == AppThemeMode.dark;
        final Color appBackgroundColor = isDark 
            ? const Color(0xFF121212) 
            : const Color(0xFFF8F9FA);

        return MaterialApp(
          title: 'Kampus Pintar',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: appBackgroundColor,
            brightness: isDark ? Brightness.dark : Brightness.light,
            ),
          home: const LoginScreen(),
        );
      },
    );
  }
}