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

/// Lebar ambang untuk berpindah dari navbar bawah ke rail samping.
///
/// Di Web/laptop bilah bawah selebar 1366dp menyebar lima tab sejauh ±270dp
/// satu sama lain: ikon dan labelnya jadi terpisah jauh dan bilahnya terbaca
/// sebagai deretan tombol lepas, bukan navigasi. Ambang ini sama dengan
/// ambang desktop dashboard (980dp) supaya seluruh aplikasi berpindah bentuk
/// pada lebar yang sama.
const double _minLebarDesktop = 980;

/// Lebar rail samping saat diperluas (ikon + label sebaris).
///
/// 208dp memberi ruang untuk "Perkuliahan" 12.5pt (≈66dp) plus padding kiri
/// indikator; lebih sempit dari ini labelnya mulai terpotong.
const double _lebarRail = 208;

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

  /// Satu tab navigasi: ikon outlined, ikon terisi, dan labelnya.
  ///
  /// Satu daftar dipakai dua bentuk navigasi (rail samping di desktop, bilah
  /// bawah di HP) supaya urutan tab dan labelnya tidak pernah beda.
  static const List<({IconData ikon, IconData ikonAktif, String label})> _tabs = [
    (ikon: Icons.home_outlined, ikonAktif: Icons.home, label: 'Dashboard'),
    (
      ikon: Icons.calendar_today_outlined,
      ikonAktif: Icons.calendar_today,
      label: 'Akademik',
    ),
    (
      ikon: Icons.menu_book_outlined,
      ikonAktif: Icons.menu_book,
      label: 'Perkuliahan',
    ),
    (
      ikon: Icons.account_balance_wallet_outlined,
      ikonAktif: Icons.account_balance_wallet,
      label: 'Keuangan',
    ),
    (ikon: Icons.person_outline, ikonAktif: Icons.person, label: 'Akun'),
  ];

  /// Satu tab navbar bawah.
  ///
  /// Ikon dibungkus kotak berukuran tetap, dan tab aktif mendapat pil
  /// berwarna di belakang ikonnya. Sebelumnya navbar hanya membedakan tab
  /// aktif lewat warna ikon — kontrasnya terlalu tipis, jadi saat aplikasi
  /// baru dibuka tidak kelihatan tab mana yang sedang dipakai.
  BottomNavigationBarItem _itemNav(
    ({IconData ikon, IconData ikonAktif, String label}) tab,
    AppPalette p,
  ) {
    return BottomNavigationBarItem(
      // Varian outlined untuk tab tidak aktif, filled untuk yang aktif.
      icon: _kotakIkon(Icon(tab.ikon)),
      activeIcon: _kotakIkon(Icon(tab.ikonAktif), warnaPil: p.navPill),
      label: tab.label,
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

  /// Bilah navigasi bawah — bentuk untuk HP.
  ///
  /// Dulu bilah ini memakai warna yang sama persis dengan kartu di halaman,
  /// jadi menyatu dengan konten dan tidak terbaca sebagai navigasi. Sekarang
  /// ada garis pemisah + bayangan ke atas supaya bilahnya "mengambang" di
  /// atas isi layar.
  Widget _buildBilahBawah(AppPalette p) {
    return DecoratedBox(
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
        items: [for (final tab in _tabs) _itemNav(tab, p)],
      ),
    );
  }

  /// Rail navigasi samping — bentuk untuk Web/laptop.
  ///
  /// Bilah bawah selebar 1366dp menyebar lima tabnya sejauh ±270dp; ikon dan
  /// label tiap tab jadi tidak lagi terbaca sebagai satu unit. Rail vertikal
  /// memakai lebar tetap 208dp dan menumpuk tabnya, sehingga sisanya (≥1150dp)
  /// seluruhnya jadi ruang konten.
  Widget _buildRail(AppPalette p) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.navSurface,
        border: Border(right: BorderSide(color: p.navBorder)),
      ),
      child: NavigationRail(
        extended: true,
        minExtendedWidth: _lebarRail,
        backgroundColor: Colors.transparent,
        // Jangan set `elevation: 0`. NavigationRail meng-assert
        // `elevation == null || elevation > 0`, jadi nilai 0 langsung
        // melempar assertion di mode debug (layar merah di Web).
        // null = tanpa bayangan, persis yang diinginkan di sini.
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        indicatorColor: p.navPill,
        // Font terpilih dan tidak terpilih sama besar — alasannya sama
        // dengan bilah bawah: label tidak boleh bergeser saat tab diketuk.
        selectedIconTheme: IconThemeData(
          color: p.navSelected,
          size: _ukuranIkonNav,
        ),
        unselectedIconTheme: IconThemeData(
          color: p.navUnselected,
          size: _ukuranIkonNav,
        ),
        selectedLabelTextStyle: TextStyle(
          fontSize: _ukuranLabelNav,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.15,
          color: p.navSelected,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontSize: _ukuranLabelNav,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.15,
          color: p.navUnselected,
        ),
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          // Lebar dikunci: NavigationRail memberi `leading` lebar tak terbatas,
          // dan Row berisi Expanded di dalamnya meledak dengan pesan
          // "non-zero flex but incoming width constraints are unbounded".
          child: SizedBox(
            width: _lebarRail - 24,
            child: Row(
              children: [
                Icon(Icons.school, color: p.navSelected, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Kampus Pintar',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: p.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        destinations: [
          for (final tab in _tabs)
            NavigationRailDestination(
              icon: Icon(tab.ikon),
              selectedIcon: Icon(tab.ikonAktif),
              label: Text(tab.label),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: p.overlay,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= _minLebarDesktop;

              // IndexedStack: semua tab tetap hidup, jadi posisi scroll dan isi
              // form tidak hilang saat berpindah tab. Sebelumnya
              // `body: _pages[_selectedIndex]` membangun ulang halaman dari nol
              // setiap kali tab diganti.
              final isi = IndexedStack(index: _selectedIndex, children: _pages);

              return Scaffold(
                body: desktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildRail(p),
                          Expanded(child: isi),
                        ],
                      )
                    : isi,
                bottomNavigationBar: desktop ? null : _buildBilahBawah(p),
              );
            },
          ),
        );
      },
    );
  }
}