import 'package:flutter/material.dart';
import 'package:app_kampus/screens/dashboard_screen.dart';
import 'package:app_kampus/screens/akademik_screen.dart';
import 'package:app_kampus/screens/perkuliahan_screen.dart';
import 'package:app_kampus/screens/keuangan_screen.dart';
import 'package:app_kampus/screens/akun_screen.dart';
import 'package:app_kampus/theme_notifier.dart'; // Import pusat tema global

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar 5 halaman sesuai desain
  final List<Widget> _pages = [
    const DashboardScreen(),
    const AkademikScreen(),
    const PerkuliahanScreen(),
    const KeuanganScreen(),
    const AkunScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Bungkus dengan ValueListenableBuilder (Pasang Telinga)
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, currentTheme, child) {
        
        // 2. Cek status tema saat ini
        final bool isDark = currentTheme == AppThemeMode.dark;
        final bool isLgbt = currentTheme == AppThemeMode.lgbt;

        // 3. Siapkan warna dinamis
        // Jika Dark = abu-abu gelap, jika LGBT = putih transparan, default = putih bersih
        final Color navBackgroundColor = isDark 
            ? const Color(0xFF1E1E1E) 
            : (isLgbt ? Colors.white.withOpacity(0.85) : Colors.white);
            
        // Warna untuk icon yang TIDAK diklik
        final Color unselectedColor = isDark ? Colors.grey.shade500 : Colors.grey;
        
        // Warna untuk icon yang SEDANG diklik
        final Color selectedColor = isLgbt ? Colors.purpleAccent : Colors.blueAccent;

        // 4. Return Scaffold kamu yang asli, tapi sekarang warnanya dinamis
        return Scaffold(
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            // --- TAMBAHAN BARU: Masukkan warna background navbar di sini ---
            backgroundColor: navBackgroundColor, 
            
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            
            // --- GANTI WARNA STATIS DENGAN VARIABEL ---
            selectedItemColor: selectedColor,
            unselectedItemColor: unselectedColor,
            
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Akademik'),
              BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Perkuliahan'),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Keuangan'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Akun'),
            ],
          ),
        );
      },
    );
  }
}