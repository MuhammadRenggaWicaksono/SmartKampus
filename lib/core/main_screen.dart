import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_kampus/core/theme_builder.dart';
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
  static const List<Widget> _pages = [
    DashboardScreen(),
    AkademikScreen(),
    PerkuliahanScreen(),
    KeuanganScreen(),
    AkunScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) {
        final Color unselectedColor = p.textSecondary;
        final Color selectedColor = p.isLgbt ? Colors.purpleAccent : p.accent;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: p.overlay,
          child: Scaffold(
            // IndexedStack: semua tab tetap hidup, jadi posisi scroll dan isi
            // form tidak hilang saat berpindah tab. Sebelumnya
            // `body: _pages[_selectedIndex]` membangun ulang halaman dari nol
            // setiap kali tab diganti.
            body: IndexedStack(index: _selectedIndex, children: _pages),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: p.card,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: selectedColor,
              unselectedItemColor: unselectedColor,
              // Font-size bawaan Flutter adalah 14 untuk tab aktif dan 12 untuk
              // yang lain. Begitu tab diketuk, labelnya membesar 2pt dan seluruh
              // baris bergeser — itu yang bikin navbar terlihat "tidak rata".
              // Lebih parah: "Perkuliahan" di slot 72dp terpotong jadi
              // "Perkuliah…" saat terpilih. Disamakan jadi 11.5 supaya muat
              // dan tidak ada pergeseran.
              selectedFontSize: 11.5,
              unselectedFontSize: 11.5,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Akademik',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book),
                  label: 'Perkuliahan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet),
                  label: 'Keuangan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Akun',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
