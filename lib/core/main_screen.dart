import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/screens/dashboard_screen.dart';
import 'package:app_kampus/screens/akademik_screen.dart';
import 'package:app_kampus/screens/perkuliahan_screen.dart';
import 'package:app_kampus/screens/keuangan_screen.dart';
import 'package:app_kampus/screens/akun_screen.dart';

/// Ukuran label tab.
///
/// Slot tiap tab di layar 360dp cuma 72dp. Pada 12.5pt "Perkuliahan" (label
/// terpanjang) masih muat: ±5.3em × 12.5 ≈ 66dp, dan letterSpacing negatif
/// tipis menyisakan beberapa dp lagi. Font bawaan Flutter (14pt) memang
/// terpotong di slot ini, tapi 11.5pt yang dipakai sebelumnya terlalu kecil
/// untuk dibaca sekilas.
const double _ukuranLabelNav = 12.5;

/// Ukuran ikon tab. Naik dari 24 supaya ikut terbaca tanpa memperbesar slot.
const double _ukuranIkonNav = 25;

/// Tinggi kotak ikon (ikon + bantalan pil).
///
/// Nilainya SAMA untuk tab aktif dan tidak aktif. Kalau tab aktif lebih
/// tinggi karena pil, Flutter memusatkan tiap tab secara vertikal di dalam
/// Row dan labelnya jadi tidak sebaris — itu yang dulu membuat navbar
/// terlihat "tidak rata".
const double _tinggiKotakIkon = 34;

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

  /// Satu tab navbar.
  ///
  /// Ikon dibungkus kotak berukuran tetap, dan tab aktif mendapat pil
  /// berwarna di belakang ikonnya. Sebelumnya navbar hanya membedakan tab
  /// aktif lewat warna ikon — kontrasnya terlalu tipis, jadi saat aplikasi
  /// baru dibuka tidak kelihatan tab mana yang sedang dipakai.
  BottomNavigationBarItem _itemNav({
    required IconData ikon,
    required IconData ikonAktif,
    required String label,
    required AppPalette p,
  }) {
    return BottomNavigationBarItem(
      // Varian outlined untuk tab tidak aktif, filled untuk yang aktif.
      icon: _kotakIkon(Icon(ikon)),
      activeIcon: _kotakIkon(Icon(ikonAktif), warnaPil: p.navPill),
      label: label,
    );
  }

  Widget _kotakIkon(Widget ikon, {Color? warnaPil}) {
    return Container(
      height: _tinggiKotakIkon,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: warnaPil,
        borderRadius: BorderRadius.circular(_tinggiKotakIkon / 2),
      ),
      child: ikon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: p.overlay,
          child: Scaffold(
            // IndexedStack: semua tab tetap hidup, jadi posisi scroll dan isi
            // form tidak hilang saat berpindah tab. Sebelumnya
            // `body: _pages[_selectedIndex]` membangun ulang halaman dari nol
            // setiap kali tab diganti.
            body: IndexedStack(index: _selectedIndex, children: _pages),
            // Bilah navbar dulu memakai warna yang sama persis dengan kartu
            // di halaman, jadi menyatu dengan konten dan tidak terbaca
            // sebagai navigasi. Sekarang ada garis pemisah + bayangan ke
            // atas supaya bilahnya "mengambang" di atas isi layar.
            bottomNavigationBar: DecoratedBox(
              decoration: BoxDecoration(
                color: p.navSurface,
                border: Border(top: BorderSide(color: p.navBorder)),
                boxShadow: [
                  BoxShadow(
                    color: p.navShadow,
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                iconSize: _ukuranIkonNav,
                showUnselectedLabels: true,
                selectedItemColor: p.navSelected,
                unselectedItemColor: p.navUnselected,
                // Font tab aktif dan tidak aktif harus sama. Kalau beda,
                // labelnya membesar saat diketuk dan seluruh baris bergeser
                // — itu yang bikin navbar terlihat "tidak rata".
                selectedFontSize: _ukuranLabelNav,
                unselectedFontSize: _ukuranLabelNav,
                selectedLabelStyle: const TextStyle(
                  fontSize: _ukuranLabelNav,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.15,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: _ukuranLabelNav,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.15,
                ),
                items: [
                  _itemNav(
                    ikon: Icons.home_outlined,
                    ikonAktif: Icons.home,
                    label: 'Dashboard',
                    p: p,
                  ),
                  _itemNav(
                    ikon: Icons.calendar_today_outlined,
                    ikonAktif: Icons.calendar_today,
                    label: 'Akademik',
                    p: p,
                  ),
                  _itemNav(
                    ikon: Icons.menu_book_outlined,
                    ikonAktif: Icons.menu_book,
                    label: 'Perkuliahan',
                    p: p,
                  ),
                  _itemNav(
                    ikon: Icons.account_balance_wallet_outlined,
                    ikonAktif: Icons.account_balance_wallet,
                    label: 'Keuangan',
                    p: p,
                  ),
                  _itemNav(
                    ikon: Icons.person_outline,
                    ikonAktif: Icons.person,
                    label: 'Akun',
                    p: p,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}