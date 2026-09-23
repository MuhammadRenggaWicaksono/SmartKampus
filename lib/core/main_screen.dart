import 'package:flutter/material.dart';
import 'package:app_kampus/screens/dashboard_screen.dart';
import 'package:app_kampus/screens/akademik_screen.dart';
import 'package:app_kampus/screens/perkuliahan_screen.dart';
import 'package:app_kampus/screens/keuangan_screen.dart';
import 'package:app_kampus/screens/akun_screen.dart';

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
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Agar semua icon muncul
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Akademik'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Perkuliahan'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Keuangan'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Akun'),
        ],
      ),
    );
  }
}